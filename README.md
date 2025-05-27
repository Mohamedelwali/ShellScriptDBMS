# ShellScriptDBMS

A lightweight, menu-driven Database Management System implemented in Shell Script. `ShellScriptDBMS` enables users to create, manage, and interact with databases and tables directly from the command line, providing a practical learning tool for database concepts and shell scripting.

---

## Table of Contents

- [Features](#features)
- [Getting Started](#getting-started)
- [Usage](#usage)
- [Project Structure](#project-structure)
- [Technical Details](#technical-details)
- [Bonus Features](#bonus-features)
- [Contributing](#contributing)

---

## Features

- **CLI Menu-Based Application:** Intuitive, menu-driven interface for all operations.
- **Database Operations:**
  - Create, list, connect to, and drop databases (each database is a directory).
- **Table Operations:**
  - Create, list, and drop tables within connected databases.
- **Data Operations:**
  - Insert, select, update, and delete rows in tables.
  - Display query results in a clean, readable format.
- **Data Integrity:**
  - Define column data types and primary keys when creating tables.
  - Enforce data type and primary key constraints during insert and update operations.

---

## Getting Started

### Prerequisites

- Unix/Linux environment
- Bash or compatible shell

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Mohamedelwali/ShellScriptDBMS.git
   cd ShellScriptDBMS
   ```

2. **Run the application:**
   ```bash
  - bash ShellScriptDBMS.sh
  - sh ShellScriptDBMS.sh
  - ./ShellScriptDBMS.sh
   ```

---

## Usage

1. **Main Menu:**
   - Create Database
   - List Databases
   - Connect To Database
   - Drop Database

2. **Database Menu (after connecting):**
   - Create Table
   - List Tables
   - Drop Table
   - Insert into Table
   - Select From Table
   - Delete From Table
   - Update Table

3. **Data Validation:**
   - Specify column data types and primary key during table creation.
   - Data type and primary key constraints are enforced on insert and update.

---

## Project Structure

```
ShellScriptDBMS/
├── ShellScriptDBMS.sh    # Main application script
├── databases/            # Contains all database directories
└──README.md             # Project documentation
```

- **Databases** are stored as directories within the `databases/` folder.
- **Tables** are stored as files within their respective database directories.

---

## Technical Details

- **Shell Scripting:** All logic implemented in Bash for portability and simplicity.
- **File System-Based Storage:** Databases and tables are managed as directories and files.
- **Menu-Driven Navigation:** User-friendly CLI menus for all operations.
- **Formatted Output:** Query results are displayed in a terminal-friendly table format.

---

## Bonus Features

- **SQL Mode (Optional):** Accept SQL-like commands for advanced users.
- **GUI Mode (Optional):** Replace menu navigation with a graphical user interface.

---

## Contributing

Contributions are welcome!  
If you have suggestions, bug reports, or would like to contribute code, please open an issue or submit a pull request.

---
