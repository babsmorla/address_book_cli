# 📒 Ruby Address Book CLI

A **command-line Address Book application** written in Ruby that lets you **add, view, edit, and delete contacts**.
Supports **file-based storage** and **PostgreSQL database storage**, making it flexible for local and DB-backed usage.

---

## ✨ Features

* ✅ Add new contacts (first name, last name, phone number)
* ✅ View all contacts in a neat list
* ✅ Edit existing contacts
* ✅ Delete contacts with confirmation
* ✅ Phone number validation (`02xxxxxxx` or `05xxxxxxx`)
* ✅ Retry mechanism for invalid inputs
* ✅ Choice of storage: **File** (`book.txt`) or **PostgreSQL database**

---

## 🛠 Requirements

* **Ruby** 3.x
* **PostgreSQL** (for DB mode)
* **Bundler** (optional)

### Gems

| Gem      | Purpose                                |
| -------- | -------------------------------------- |
| `pg`     | PostgreSQL adapter                     |
| `dotenv` | Load environment variables from `.env` |

---

## ⚙️ Setup

### 1️⃣ Clone the repository

```bash
git clone <your-repo-url>
cd umar_address_book_cli
```

### 2️⃣ Install dependencies

```bash
gem install pg dotenv
```

### 3️⃣ Configure database (DB mode)

Create a `.env` file in the root:

```env
DB_HOST=127.0.0.1
DB_USER=postgres
DB_PASSWORD=your_password
DB_NAME=address_book
```

> ⚠️ Make sure `.env` is in `.gitignore` to avoid exposing your credentials.

Create the `contacts` table in PostgreSQL:

```sql
CREATE TABLE contacts (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    phone_number VARCHAR(20),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
```

---

## 🚀 Running the Application

Start the CLI:

```bash
ruby address_book_cli.rb
```

You’ll see a menu like this:

```
Welcome to the Address Book!
---------------------------
1. Add Contact
2. View Contact
3. Edit Contact
4. Delete Contact
5. Exit
```

Follow the prompts to manage your contacts.

---

## 🗂 Storage Modes

### File-Based Storage

* File: `book.txt` (auto-created if missing)
* Format: `first_name,last_name,phone_number`

### Database Storage

* PostgreSQL table `contacts`
* Configured via `.env` file
* Reads contacts automatically on startup

---

## 📋 Input Validation

| Field        | Validation Rule                                 |
| ------------ | ----------------------------------------------- |
| Phone Number | Must start with `02` or `05` and have 10 digits |
| Retry Limit  | Maximum 5 invalid attempts per input            |

---

## 🗃 Project Structure

```text
umar_address_book_cli/
│
├── address_book_cli.rb     # Main program
├── book.txt                # File storage
├── .env                    # Environment variables
├── models/
│   └── contact.rb          # Contact class
├── managers/
│   ├── file_manager.rb     # File-based storage manager
│   └── db_manager.rb       # DB storage manager
└── ui/
    └── ui.rb               # User interface & menu
```

---

## 🧩 Classes Overview

| Class / Module         | Responsibility                               |
| ---------------------- | -------------------------------------------- |
| `Contact`              | Stores individual contact data               |
| `BaseManager`          | Shared manager functionality                 |
| `FileManager::Manager` | Handles file-based storage                   |
| `DBManager::Manager`   | Handles PostgreSQL database storage          |
| `UI`                   | Handles menus, prompts, and user interaction |

---

## 💡 Notes

* `UI` class ensures smooth navigation with **retry logic**
* Each contact has a `full_name` method for easy display
* Supports **editing and deletion with confirmation**
* Flexible to switch between file and DB storage

---

## 🎨 Example Usage

### Adding a Contact

```text
Enter First Name: Umar
Enter Last Name: Mohammed
Enter Phone Number: 0541234567
Contact added successfully!
```

### Viewing Contacts

```text
1. Umar Mohammed - 0541234567
2. Jane Doe - 0212345678
```

### Editing a Contact

```text
Select the contact number to Edit: 1
Enter new First Name (press Enter to keep "Umar"):
Enter new Last Name (press Enter to keep "Mohammed"):
Enter new Phone Number (press Enter to keep "0541234567"): 0547654321
Contact updated successfully!
```

---

## 📝 License

MIT License – free to use and modify
