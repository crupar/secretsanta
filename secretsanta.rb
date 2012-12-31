require 'yaml'

class Person
  attr_accessor :name, :household, :santa

  def initialize(attrs)
    self.name = attrs["name"]
    self.household = attrs["household"]
    self.santa = attrs["santa"]
  end

  def can_be_santa_of?(other)
    @household != other.household
  end

  def already_santa_of?(other)
    @name != other.person.santa.name
  end
  
  def self.santaize(filename)
    people_config = YAML.load_file(filename)
    people = people_config['people'].map do |attrs|
      Person.new(attrs)
    end

    santas = people.dup
    
    people.each do |person|
    person.santa = santas.delete_at(rand(santas.size))
    end

    people.each do |person|
      unless person.santa.can_be_santa_of? person
        candidates = people.select do |p|
          p.santa.can_be_santa_of?(person) && person.santa.can_be_santa_of?(p)
        end
        raise if candidates.empty?
        other = candidates[rand(candidates.size)]
        temp = person.santa
        person.santa = other.santa
        other.santa = temp
        finished = false
      end
    end

    puts "Secret Santa List:"       
    people.each do |person|
      puts "#{person.name} (of clan #{person.household}) is secret santa for #{person.santa.name} (of clan #{person.santa.household})."
    end
  end

end

Person.santaize('config/people.yml')
$end