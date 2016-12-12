require_relative "../config/environment.rb"
require "pry"

class Dog

  attr_accessor :id, :name, :breed

    def initialize (id: nil, name:, breed:)
      @name = name
      @breed = breed
      @id = id
    end

    def self.create_table
      sql = <<-SQL
      CREATE TABLE if NOT EXISTS dogs(
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
      )
      SQL
      DB[:conn].execute(sql)
    end

    def self.drop_table
      sql = <<-SQL
      DROP TABLE dogs
      SQL
      DB[:conn].execute(sql)
    end

    def update
      sql = <<-SQL
      UPDATE dogs
      SET name = ?, breed = ? WHERE id = ?
      SQL
      DB[:conn].execute(sql, self.name, self.breed, self.id)
    end

    def save
      if self.id
        self.update
      else
        sql = <<-SQL
        INSERT INTO dogs(name, breed)
        VALUES (?,?)
        SQL
        DB[:conn].execute(sql, self.name, self.breed)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      end
      self
    end

    def self.create(name:, breed:)
      kido = Dog.new(name: name, breed: breed)
      kido.save
      kido
    end

    def self.new_from_db(row)
      id = row[0]
      name = row[1]
      breed = row[2]
      Dog.new(name: name, breed: breed, id: id)
    end

    def self.find_by_name(name)
      sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ?
      SQL

      result = DB[:conn].execute(sql, name).map do |row|
      self.new_from_db(row)
    end.first
    end

    def self.find_by_id(id)
      sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE id = ?
      SQL

      result = DB[:conn].execute(sql, id).map do |row|
      self.new_from_db(row)
      end.first
    end

    def self.find_or_create_by(name:, breed:)
      sql = <<-SQL
      SELECT *
      FROM dogs
      WHERE name = ? and breed = ?
      SQL
      result = DB[:conn].execute(sql, name, breed)
      if !result.empty?
        dog_data = result[0]
        dog = Dog.new(id: dog_data[0], name: dog_data[1], breed: dog_data[2])
      else
        dog = self.create(name: name, breed: breed)
      end
      dog
    end


end
