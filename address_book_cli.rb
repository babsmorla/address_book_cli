class Contact
  attr_accessor :id, :first_name, :last_name, :phone_number

  def initialize(first_name, last_name, phone_number, id = nil)
    @first_name = first_name
    @last_name = last_name
    @phone_number = phone_number
    @id = id
  end

  def full_name
    "#{first_name} #{last_name}"
  end
end

class BaseManager
  attr_accessor :contacts

  def initialize
    @contacts ||= []   # if nil, assign empty array

    init_storage
  end

  def init_storage
    raise NotImplementedError, "Subclasses must implement init storage"
  end
end

module FileManager
  class Manager < BaseManager
    FILE_NAME = "book.txt"

    def init_storage
      if File.exist?(FILE_NAME)
        read_from_file #Create create function
      else
        File.new(FILE_NAME, "w+")
      end
    end

    def save_to_file
      File.open(FILE_NAME, "w") do |file|
        @contacts.each do |contact|
          file.puts ("#{contact.first_name},#{contact.last_name},#{contact.phone_number}")
        end
      end
    end

    def read_from_file
      @contacts.clear
      File.open(FILE_NAME, "r") do |file|
        file.each_line do |line|
          first_name, last_name, phone_number = line.chomp.strip.split(",")
          @contacts << Contact.new(first_name, last_name, phone_number)
        end
      end
    end

    def add_contact(first_name, last_name, phone_number)
      @contacts << Contact.new(first_name, last_name, phone_number)
      save_to_file
    end

    def edit_contact(index, first_name, last_name, phone_number)
      contact = @contacts[index]
      contact.first_name = first_name
      contact.last_name = last_name
      contact.phone_number = phone_number
      save_to_file
    end

    def delete_contact(index)
      @contacts.delete_at(index)
      save_to_file
    end
  end
end

module DBManager
  require "pg"
  require "dotenv"
  Dotenv.load

  class Manager < BaseManager
    def init_storage
      begin
        host = ENV["DB_HOST"] 
        user = ENV["DB_USER"] 
        password = ENV["DB_PASSWORD"] 
        dbname = ENV["DB_NAME"]

        @conn = PG::Connection.open(host: host, dbname: dbname, user: user, password: password)
        read_from_db
      rescue PG::ConnectionBad => e
        puts "Database connection failed: #{e.message}"
      end
    end

    def read_from_db
      @contacts.clear
      result = @conn.exec("SELECT * FROM contacts ORDER BY created_at")
      result.each do |record|
        @contacts << Contact.new(
          record["first_name"],
          record["last_name"],
          record["phone_number"],
          record["id"].to_i
        )
      end
    end

    def add_contact(first_name, last_name, phone_number)
      query = "INSERT INTO contacts (first_name, last_name, phone_number, created_at, updated_at)
      VALUES($1, $2, $3, NOW(), NOW())"
      @conn.exec_params(query, [first_name, last_name, phone_number])
      read_from_db
    end

    def edit_contact(id, first_name, last_name, phone_number)
      query = "UPDATE contacts SET first_name = $1, last_name = $2, phone_number = $3, updated_at = NOW() WHERE id = $4"
      @conn.exec_params(query, [first_name, last_name, phone_number, id])
      read_from_db
    end

    def delete_contact(id)
      query = "DELETE FROM contacts WHERE id = $1"
      @conn.exec_params(query, [id])
      read_from_db
    end
  end
end

class UI
  MAX_RETRIES = 5

  def initialize
    @manager = DBManager::Manager.new
    main_menu
  end

  def main_menu
    loop do
      options = [
        { text: "Add Contact", action: -> { add_contact_flow } },
        { text: "View Contact", action: -> { view_contact_flow } },
        { text: "Edit Contact", action: -> { contact_selection_flow("Edit") } },
        { text: "Delete Contact", action: -> { contact_selection_flow("Delete") } },
        { text: "Exit", action: -> { puts "Goodbye! 👋"; exit } },
      ]

      header = "Welcome to the Address Book!\n" +
               "---------------------------\n" +
               "Please choose an option: "

      render_menu(header, options, retry_limit: nil, error_msg: "Invalide option, Please try again.") #takes 5 args 2-must, 3-optional
    end
  end

  private

  def render_menu(header, options, retry_limit: nil, error_msg: "Invalid selection. Try again.", prompt: "Choice: ")
    count = 0
    loop do
      puts "\n#{header}"
      options.each_with_index do |opt, i|
        puts "#{i + 1}. #{opt[:text]}"
      end # do & end can be replaced with {  }

      print "#{prompt}"

      input = gets.chomp
      idx = input.to_i - 1

      if input.match?(/^\d+$/) && idx >= 0 && idx < options.length
        return options[idx][:action].call if options[idx][:action]
        return idx
      end

      count += 1
      return :stop if exceeded_limit?(count, retry_limit)
      puts error_msg
    end
  end

  def attempt_count(count)
    puts "#{MAX_RETRIES - count} Attempts Remaining"
  end

  def exceeded_limit?(count, limit)
    return false unless limit
    if count >= limit
      puts "\nToo many invalid attempts. Returning to main menu."
      return true
    else
      return false
    end
  end

  def add_contact_flow
    puts "\n---- Add a New Contact -----"
    data = prompt_contact_details
    return if data.nil? #this prevents summary flow from running if data is nil or user cancels
    summary_confirmation_flow(data)
  end

  def prompt_contact_details(defaults = {})
    fields = [
      { key: :first_name, label: "Enter First Name: " },
      { key: :last_name, label: "Enter Last Name: " },
      { key: :phone_number, label: "Enter Phone Number: ", validator: ->(val) { val.match?(/^(02|05)\d{8}$/) } },
    ]

    results = {}
    fields.each do |field|
      val = prompt_with_retry(field[:label], default: defaults[field[:key]], validator: field[:validator])
      return nil if val == :stop
      results[field[:key]] = val
    end
    return results
  end

  def attempts_count(count)
    puts "#{MAX_RETRIES - count} remaining attempts"
  end

  def prompt_with_retry(prompt_text, default: nil, validator: nil)
    count = 0
    loop do
      print "#{prompt_text}"
      input = gets.chomp
      input = default if input.empty? && default

      valid = !input.empty?
      valid = valid && validator.call(input) if validator && valid

      return input if valid

      count += 1
      return :stop if exceeded_limit?(count, MAX_RETRIES)
      puts "Invalid input. Try Again."
    end
  end

  def summary_confirmation_flow(data)
    header = "-----Summary-------\n" +
             "First Name: #{data[:first_name]}\n" +
             "Last Name: #{data[:last_name]}\n" +
             "Phone Number: #{data[:phone_number]}\n" +
             "What would you like to do next?"

    options = [
      { text: "Save Contact", action: -> { save_contact(data) } },
      { text: "Edit Details", action: -> {
        new_data = prompt_edit_details(data)
        summary_confirmation_flow(new_data)
      } },
      { text: "Cancel and return to Main Menu", action: -> { nil } },
    ]

    render_menu(header, options, retry_limit: MAX_RETRIES, error_msg: "Invalid selection. Please try Again")
  end

  def prompt_edit_details(data)
    f = prompt_with_default("Enter new First Name", data[:first_name])
    l = prompt_with_default("Enter new Last Name", data[:last_name])
    p = prompt_with_default("Enter new Phone Number", data[:phone_number])

    { id: data[:id], first_name: f, last_name: l, phone_number: p } # add default id for Db
  end

  def prompt_with_default(label, current_val)
    print "#{label} (press Enter to keep \"#{current_val}\"): "
    input = gets.chomp
    input.empty? ? current_val : input
  end

  def save_contact(data)
    if data[:id]
      @manager.edit_contact(data[:id], data[:first_name], data[:last_name], data[:phone_number])
      puts "\nContact updated successfully!"
    else
      @manager.add_contact(data[:first_name], data[:last_name], data[:phone_number])
      puts "\nContact added successfully!"
    end
  end

  def view_contact_flow
    puts "\n-------Your Contacts---------"
    if @manager.contacts.empty?
      puts "No contacts found."
    else
      @manager.contacts.each_with_index do |c, i|
        puts "#{i + 1}. #{c.full_name} - #{c.phone_number}"
      end
    end
  end

  def contact_selection_flow(mode)
    if @manager.contacts.empty?
      puts "\n------#{mode} a Contact ------\n No contacts found."
      return
    end

    header = "-------- #{mode} a Contact-------\nSelect the number of the contact to #{mode.downcase}:"

    options = @manager.contacts.map do |c|
      { text: "#{c.full_name} - #{c.phone_number}", action: nil }
    end

    result = render_menu(header, options, retry_limit: MAX_RETRIES, prompt: "Select: ")
    return if result == :stop

    contact = @manager.contacts[result]
    if mode == "Edit"
      #assign id: as id from db or index from input
      data = { id: (contact.id || result), first_name: contact.first_name, last_name: contact.last_name, phone_number: contact.phone_number }
      summary_confirmation_flow(data)
    else
      delete_confirmation_flow(contact, result)
    end
  end

  def delete_confirmation_flow(contact, idx)
    count = 0
    loop do
      print "Are you sure you want to delete \"#{contact.full_name}\"? (y/n) "

      case gets.chomp.downcase
      when "y" then @manager.delete_contact(contact.id || idx); puts "Contact deleted."
return
      when "n" then puts "Contact Deletion Canceled."; exit
      else
        puts "Invalid Selection. Try Again"
        attempt_count(count)
        count += 1
        return :abort if exceeded_limit?(count, MAX_RETRIES)
      end
    end
  end
end

UI.new
