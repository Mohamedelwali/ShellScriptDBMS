---

# ShellScriptDBMS

**ShellScriptDBMS** is a lightweight, menu-driven Database Management System implemented entirely in Shell Script. It allows users to create, manage, and interact with databases and tables from the command line, serving as an excellent tool for learning both database concepts and shell scripting.

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

* **Command Line Interface (CLI):** Menu-based navigation for ease of use.
* **Database Operations:**

  * Create, list, connect to, and delete databases (each as a directory).
* **Table Operations:**

  * Create, list, and delete tables within connected databases.
* **Data Operations:**

  * Insert, select, update, and delete records.
  * Output displayed in a clean, tabular format.
* **Data Integrity:**

  * Support for data types and primary key constraints.
  * Validations enforced during insert and update operations.

---

## 🚀 Getting Started

### 📋 Prerequisites

* Unix/Linux system
* Bash or compatible shell

### 🛠 Installation

1. Clone the repository:

   ```bash
   git clone https://github.com/Mohamedelwali/ShellScriptDBMS.git
   cd ShellScriptDBMS
   ```

2. Run the application using any of the following:

   ```bash
   bash ShellScriptDBMS.sh
   # or
   sh ShellScriptDBMS.sh
   # or (make it executable first)
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

* Column data types and primary keys are defined during table creation.
* Validations enforce:

  * Correct data types on insert/update.
  * Uniqueness of primary key values.

---

## 📁 Project Structure

```
ShellScriptDBMS/
├── ShellScriptDBMS.sh      # Main application script
├── databases/              # Contains all database directories
└── README.md               # Project documentation
```

* **Databases**: Represented as directories inside the `databases/` folder.
* **Tables**: Represented as text files inside each respective database directory.

---

## ⚙️ Technical Details

* **Shell Script**: Fully implemented in Bash for simplicity and portability.
* **Filesystem-Based DBMS**: Databases and tables stored as folders and files.
* **Menu Navigation**: Clear CLI menus guide users through operations.
* **Formatted Output**: Displays results in a readable tabular form in the terminal.

---

## 🌟 Bonus Features

> *These features are planned or optional enhancements:*

* **SQL Mode (Optional):** Support for parsing SQL-like queries for advanced users.
* **GUI Mode (Optional):** A graphical user interface to replace CLI menus.

---

## 🤝 Contributing

Contributions are welcome!
To contribute:

1. Fork the repository.
2. Create a new branch (`git checkout -b feature-name`).
3. Make your changes and commit them.
4. Push to the branch (`git push origin feature-name`).
5. Open a Pull Request.

---

Let me know if you'd like this converted to a `README.md` file or hosted as a documentation site!
