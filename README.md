---

# 🐚 ShellScriptDBMS

**ShellScriptDBMS** is a lightweight, menu-driven Database Management System implemented entirely in Shell Script. It allows users to create, manage, and interact with databases and tables directly from the command line — a great tool for learning database fundamentals and shell scripting.

---

## 📑 Table of Contents

* [Features](#features)
* [Getting Started](#getting-started)

  * [Prerequisites](#prerequisites)
  * [Installation](#installation)
* [Usage](#usage)

  * [Main Menu](#main-menu)
  * [Database Menu](#database-menu)
  * [Data Validation](#data-validation)
* [Project Structure](#project-structure)
* [Technical Details](#technical-details)
* [Bonus Features](#bonus-features)
* [Contributing](#contributing)

---

## ✅ Features

* **Command-Line Interface (CLI):** User-friendly, menu-based navigation.
* **Database Operations:**

  * Create, list, connect to, and delete databases (directories).
* **Table Operations:**

  * Create, list, and delete tables (files) within a database.
* **Data Operations:**

  * Insert, select, update, and delete table records.
  * Display output in a readable, formatted table.
* **Data Integrity:**

  * Define column data types and primary keys.
  * Enforce data type and primary key constraints on inserts and updates.

---

## 🚀 Getting Started

### 📋 Prerequisites

* Unix/Linux operating system
* Bash or a compatible shell

### 🛠 Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/Mohamedelwali/ShellScriptDBMS.git
   cd ShellScriptDBMS
   ```

2. Run the application using any of the following:

   ```bash
   bash ShellScriptDBMS.sh
   # OR
   sh ShellScriptDBMS.sh
   # OR
   chmod +x ShellScriptDBMS.sh
   ./ShellScriptDBMS.sh
   ```

---

## 💡 Usage

### 🧭 Main Menu

* Create Database
* List Databases
* Connect to Database
* Drop Database

### 🗂 Database Menu (after connecting)

* Create Table
* List Tables
* Drop Table
* Insert into Table
* Select from Table
* Delete from Table
* Update Table

### 🛡 Data Validation

* Specify column data types and primary key during table creation.
* On insert/update:

  * Validate data type.
  * Ensure primary key uniqueness.

---

## 📁 Project Structure

```
ShellScriptDBMS/
├── ShellScriptDBMS.sh      # Main application script
├── databases/              # Stores all databases as directories
└── README.md               # Project documentation
```

* **Databases:** Represented as directories inside the `databases/` folder.
* **Tables:** Represented as text files within their respective database directories.

---

## ⚙️ Technical Details

* **Language:** Pure Bash scripting for simplicity and system compatibility.
* **Storage Mechanism:** File-system-based (directories for databases, files for tables).
* **User Interface:** Menu-driven with text-based selections.
* **Display:** Clean, tabular formatting for data presentation in terminal.

---

## 🌟 Bonus Features

> *Planned or optional future enhancements:*

* **SQL Mode:** Support for SQL-like commands for power users.
* **GUI Mode:** A graphical interface to replace CLI-based interaction.

---

## 🤝 Contributing

Contributions are welcome!

To contribute:

1. Fork this repository.
2. Create a new feature branch:

   ```bash
   git checkout -b feature-name
   ```
3. Commit your changes:

   ```bash
   git commit -m "Add some feature"
   ```
4. Push to your branch:

   ```bash
   git push origin feature-name
   ```
5. Open a Pull Request.

---

Let me know if you'd like this deployed as a documentation site (e.g., GitHub Pages or MkDocs).

Would you like me to convert this into a downloadable `README.md` file or auto-push it to your GitHub repo?
