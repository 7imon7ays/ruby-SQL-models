require 'singleton'
require 'sqlite3'

class QuestionsDatabase < SQLite3::Database
  include Singleton

  def initialize
    super("questions.db")

    # otherwise each row is returned as an array of values; we want a hash
    # indexed by column name.
    self.results_as_hash = true

    # otherwise all the data is returned as strings and not parsed into the
    # appropriate type.
    self.type_translation = true
  end

end

class Table

  def initialize(fields)
    @fields = fields
  end

  def method_missing(field)
    field = field.to_s
    raise NoMethodError.new("#{field} is not a valid field") unless @fields.has_key?(field)
    @fields[field]
  end

  def self.find(table, field, value)
    rows = QuestionsDatabase.instance.execute(
      "SELECT * FROM #{table} WHERE #{field} = ?", value)
    rows.map { |row| self.new(row) }
  end

  def self.find_by_id(table, id)
    row = QuestionsDatabase.instance.get_first_row(
      "SELECT * FROM #{table} WHERE id = ?", id)
    self.new(row)
  end

  def self.query(query, *values)
    rows = QuestionsDatabase.instance.execute(query, *values)
    rows.map { |row| self.new(row) }
  end

end


class Question < Table

  def self.find_by_id(id)
    super('questions', id)
  end

  def self.find_by_author_id(id)
    self.find('questions', 'author_id', id)
  end

  def replies
    Reply::find_by_question_id(@fields['id'])
  end

  def followers
    QuestionFollower.followers_for_question_id(@fields['id'])
  end

end



class User < Table

  def self.find_by_id(id)
    super('users', id)
  end

  def self.find_by_name(fname, lname)
    rows = QuestionsDatabase.instance.execute(
      "SELECT * FROM users WHERE fname = ? AND lname = ?", fname, lname)
      self.new(rows.first)
  end

  def authored_questions
    Question::find_by_author_id(@fields['id'])
  end

  def authored_replies
    Reply::find_by_author_id(@fields['id'])
  end

  def followed_questions
    QuestionFollower.followed_questions_for_user_id(@fields['id'])
  end

end



class QuestionFollower < Table

  def self.followers_for_question_id(question_id)
    query = <<-SQL
     SELECT users.*
       FROM users
       JOIN question_followers
         ON users.id = follower_id
      WHERE question_id = ?;
    SQL
    self.query(query, question_id)
  end

  def self.followed_questions_for_user_id(user_id)
    query = <<-SQL
     SELECT questions.*
       FROM questions
       JOIN question_followers
         ON questions.id = question_id
      WHERE follower_id = ?;
    SQL
    self.query(query, user_id)
  end

  def self.most_followed_questions(n)
    query = <<-SQL
      SELECT questions.*
        FROM questions
        JOIN question_followers
          ON questions.id = question_id
    GROUP BY question_id
    ORDER BY COUNT(*) desc
       LIMIT ?
    SQL
    Question.query(query, n)
  end

end



class Reply < Table

  def self.find_by_id(id)
    super('replies', id)
  end

  def self.find_by_author_id(id)
    self.find('replies', 'author_id', id)
  end

  def self.find_by_question_id(id)
    self.find('replies', 'question_id', id)
  end

  def author
    User.find_by_id(@fields['author_id'])
  end

  def question
    Question.find_by_id(@fields['question_id'])
  end

  def parent_reply
    Reply.find_by_id(@fields['parent_reply_id'])
  end

  def child_replies
    query = <<-SQL
    SELECT child.*
      FROM replies child
      JOIN replies parent
        ON child.parent_reply_id = parent.id
     WHERE parent.id = ?;
    SQL
    Reply.query(query, @fields['id'])
  end

end


class QuestionLike < Table

  def self.likers_for_question_id(question_id)
    query = <<-SQL
     SELECT users.*
       FROM users
       JOIN question_likes
         ON users.id = liker_id
      WHERE question_id = ?;
    SQL
    self.query(query, question_id)
  end

  def self.liked_questions_for_user_id(user_id)
    query = <<-SQL
     SELECT questions.*
       FROM questions
       JOIN question_likes
         ON questions.id = question_id
      WHERE liker_id = ?;
    SQL
    self.query(query, user_id)
  end

  def self.num_likes_for_question_id(question_id)
    query = <<-SQL
     SELECT COUNT(*) likes
       FROM users
       JOIN question_likes
         ON users.id = liker_id
      WHERE question_id = ?;
    SQL
    row = QuestionsDatabase.instance.get_first_row(
      query, question_id)
    row['likes']
  end

end