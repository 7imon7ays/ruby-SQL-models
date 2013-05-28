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
    raise "not a valid field" unless @fields.has_key?(field)
    @fields[field]
  end

  def self.find(table, field, value)
    rows = QuestionsDatabase.instance.execute(
      "SELECT * FROM ? WHERE ? = ?", table, field, value)
    rows.map { |row| self.new(row) }
  end

  def self.find_by_id(table, id)
    rows = QuestionsDatabase.instance.execute(
      "SELECT * FROM ? WHERE id = ?", table, id)
    self.new(rows.first)
  end

end




class Question < Table

  def self.find_by_id(id)
    super('questions', id)
    # rows = QuestionsDatabase.instance.execute(
#       "SELECT * FROM questions WHERE id = ?", id)
#     self.new(rows.first)
  end

  def self.find_by_author_id(id)
    rows = QuestionsDatabase.instance.execute(
      "SELECT * FROM questions WHERE author_id = ?", id)
    rows.map { |row| self.new(row) }
  end

  def replies
    Reply::find_by_question_id(@fields['id'])
  end

end



class User < Table

  def self.find_by_id(id)
    row = QuestionsDatabase.instance.first_row(
      "SELECT * FROM users WHERE id = ?", id)
    self.new(row)
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

end



class QuestionFollower < Table

end



class Reply < Table

  def self.find_by_id(id)
    rows = QuestionsDatabase.instance.execute(
      "SELECT * FROM replies WHERE id = ?", id)
    self.new(rows.first)
  end

  def self.find_by_author_id(id)
    rows = QuestionsDatabase.instance.execute(
      "SELECT * FROM replies WHERE author_id = ?", id)
    rows.map { |row| self.new(row) }
  end

  def self.find_by_question_id(id)
    rows = QuestionsDatabase.instance.execute(
      "SELECT * FROM replies WHERE question_id = ?", id)
    rows.map { |row| self.new(row) }
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

end



class QuestionLike < Table

end