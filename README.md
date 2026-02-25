Ruby Address Book CLI

A command-line Address Book application in Ruby that allows you to add, view, edit, and delete contacts. The project supports two storage options:

File-based storage using book.txt

PostgreSQL database storage using environment variables for connection

Features

Add new contacts with first name, last name, and phone number

View a list of all contacts

Edit existing contacts

Delete contacts with confirmation

Input validation for phone numbers (02xxxxxxx or 05xxxxxxx)

Retry logic for invalid inputs

Supports both file-based and database-based storage

Requirements

Ruby 3.x

PostgreSQL (for DB mode)

Bundler (optional, if using gems)

Gems Used

pg – PostgreSQL database adapter

dotenv – Load environment variables from .env

Setup
1. Clone the repository
git clone <your-repo-url>
cd umar_address_book_cli
2. Install dependencies
gem install pg dotenv
3. Configure database (for DB mode)

Create a .env file in the project root:

DB_HOST=127.0.0.1
DB_USER=postgres
DB_PASSWORD=your_password
DB_NAME=address_book

Make sure .env is ignored in Git (.gitignore contains .env) to protect sensitive credentials.

Create the contacts table in PostgreSQL if using DB storage:

CREATE TABLE contacts (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    phone_number VARCHAR(20),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
Running the Application
ruby address_book_cli.rb

You will see a menu with options:

1. Add Contact
2. View Contact
3. Edit Contact
4. Delete Contact
5. Exit

Follow the prompts to manage your contacts.

File-Based Storage

Uses book.txt in the project root

Each contact is stored as first_name,last_name,phone_number

Automatically created if it doesn’t exist

Database Storage

Uses PostgreSQL

Configured via .env file

Automatically reads contacts from the database on startup

Input Validation

Phone numbers must start with 02 or 05 and be 10 digits long

Maximum retry attempts: 5 for invalid input

Summary confirmation before saving or editing contacts

Project Structure
umar_address_book_cli/
│
├── address_book_cli.rb     # Main program entry
├── book.txt                # File storage (auto-created)
├── .env                    # Environment variables (ignored in git)
├── models/
│   └── contact.rb          # Contact class definition
├── managers/
│   ├── file_manager.rb     # FileManager module
│   └── db_manager.rb       # DBManager module
└── ui/
    └── ui.rb               # UI flow and menu logic
Notes

Contact class stores individual contact details

BaseManager provides shared functionality for storage managers

FileManager::Manager handles file-based persistence

DBManager::Manager handles database persistence

UI class manages all user interactions

License

MIT License – free to use and modify
