# vim-dadbod-ui Architecture Report

## Executive Summary

vim-dadbod-ui is a Vim plugin that provides a user interface for database interactions built on top of vim-dadbod. It implements a drawer-based navigation system for managing multiple database connections, executing queries, and managing saved queries. The architecture follows a modular design with clear separation of concerns between UI management, database operations, and user interactions.

## 1. Directory Structure

```
vim-dadbod-ui/
├── plugin/                    # Plugin entry points and global configuration
│   └── db_ui.vim             # Main plugin registration and commands
├── autoload/                  # Core implementation modules
│   ├── db_ui.vim            # Main API and database management
│   └── db_ui/               # Specialized modules
│       ├── connections.vim  # Connection management
│       ├── drawer.vim       # UI drawer implementation
│       ├── query.vim        # Query execution and buffer management
│       ├── schemas.vim      # Database schema support
│       ├── notifications.vim # User notification system
│       ├── table_helpers.vim # Table-specific operations
│       ├── dbout.vim        # Query result handling
│       └── utils.vim        # Utility functions
├── ftplugin/                 # Filetype-specific configurations
│   ├── dbui.vim             # DBUI buffer mappings
│   ├── dbout.vim            # Query result buffer mappings
│   ├── sql.vim              # SQL query buffer mappings
│   └── javascript.vim       # MongoDB query buffer mappings
├── syntax/                   # Syntax highlighting
│   └── dbout.vim            # Query result syntax
├── doc/                      # Documentation
├── test/                     # Test suite
└── .Brain/                   # Architecture documentation
```

## 2. Entry Points

### Primary Entry Points

1. **plugin/db_ui.vim** - Main plugin entry point
   - Registers global commands (DBUI, DBUIToggle, DBUIClose, etc.)
   - Sets up global configuration variables
   - Defines autocommands for file handling
   - Initializes icon configurations

2. **autoload/db_ui.vim** - Main API gateway
   - `db_ui#open()` - Opens the main UI drawer
   - `db_ui#toggle()` - Toggles drawer visibility
   - `db_ui#close()` - Closes the drawer
   - `db_ui#connections_list()` - Returns connection information
   - `db_ui#find_buffer()` - Associates buffers with databases

### Secondary Entry Points

3. **ftplugin/*.vim** - Context-specific functionality
   - Buffer-local mappings for different filetypes
   - Specialized behavior for query buffers vs result buffers

## 3. Core Abstractions

### 3.1 Main Application Class (`s:dbui`)

**Location**: `autoload/db_ui.vim`

**Responsibilities**:
- Database connection management
- Configuration resolution from multiple sources
- Schema information population
- Connection lifecycle management

**Key Methods**:
- `new()` - Factory method for instance creation
- `populate_dbs()` - Aggregates connections from all sources
- `connect()` - Establishes database connections
- `generate_new_db_entry()` - Creates database metadata structures

### 3.2 UI Drawer (`s:drawer`)

**Location**: `autoload/db_ui/drawer.vim`

**Responsibilities**:
- Tree-like UI rendering and navigation
- Buffer management for the drawer interface
- User interaction handling (selections, expansions)
- Visual state management

**Key Methods**:
- `open()` - Creates and configures the drawer buffer
- `render()` - Updates the UI display
- `toggle_line()` - Handles item selection/expansion
- `get_current_item()` - Retrieves focused UI element

### 3.3 Query Manager (`s:query`)

**Location**: `autoload/db_ui/query.vim`

**Responsibilities**:
- Query buffer lifecycle management
- Query execution coordination
- Result buffer association
- Bind parameter handling

**Key Methods**:
- `open()` - Creates query buffers for tables/saved queries
- `execute_query()` - Coordinates query execution
- `generate_buffer_name()` - Creates unique buffer identifiers

### 3.4 Connection Manager (`s:connections`)

**Location**: `autoload/db_ui/connections.vim`

**Responsibilities**:
- Persistent connection storage
- Connection CRUD operations
- Connection file I/O operations

### 3.5 Schema Support (`s:schemas`)

**Location**: `autoload/db_ui/schemas.vim`

**Responsibilities**:
- Database-specific query templates
- Schema introspection queries
- Result parsing for different database types

### 3.6 Notification System

**Location**: `autoload/db_ui/notifications.vim`

**Responsibilities**:
- User feedback and error reporting
- Multiple notification backends (vim, neovim)
- Message formatting and timing

## 4. Cross-Module Dependencies

### Dependency Graph

```
plugin/db_ui.vim
    ↓
autoload/db_ui.vim (Main API)
    ├── drawer.vim (UI Management)
    ├── connections.vim (Connection Management)
    ├── query.vim (Query Execution)
    ├── schemas.vim (Database Support)
    ├── notifications.vim (User Feedback)
    └── utils.vim (Utilities)
        ↓
ftplugin/*.vim (Context-specific behavior)
```

### Key Dependencies

1. **Main Module Dependencies**:
   - `db_ui.vim` depends on all `db_ui/*` modules
   - `drawer.vim` depends on `query.vim` for buffer operations
   - `query.vim` depends on `schemas.vim` for query templates
   - All modules depend on `notifications.vim` for user feedback

2. **External Dependencies**:
   - **vim-dadbod**: Core database connectivity
   - **vim-dotenv**: Environment variable management (optional)
   - **nvim-notify**: Enhanced notifications (optional, Neovim only)

3. **Configuration Flow**:
   - Global variables → Plugin configuration → Module behavior
   - Multiple configuration sources: env vars, global vars, JSON files

## 5. System Architecture

### 5.1 Architectural Patterns

1. **Singleton Pattern**: Main `dbui` instance ensures single point of state management
2. **Factory Pattern**: `new()` functions for object creation across modules
3. **Observer Pattern**: Autocommands for buffer and window event handling
4. **Strategy Pattern**: Database-specific implementations in schemas module

### 5.2 Component Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    User Interface Layer                      │
├─────────────────────────────────────────────────────────────┤
│  Drawer UI  │  Query Buffers  │  Result Buffers  │  Notifications │
└─────────────────────────────────────────────────────────────┘
                                ↓
┌─────────────────────────────────────────────────────────────┐
│                    Application Layer                        │
├─────────────────────────────────────────────────────────────┤
│  Main API  │  Connection Mgmt  │  Query Execution  │  Utils │
└─────────────────────────────────────────────────────────────┘
                                ↓
┌─────────────────────────────────────────────────────────────┐
│                    Database Layer                           │
├─────────────────────────────────────────────────────────────┤
│  Schema Support  │  Table Helpers  │  vim-dadbod Integration │
└─────────────────────────────────────────────────────────────┘
```

### 5.3 Data Flow Architecture

1. **Configuration Flow**: Multiple sources → unified configuration
2. **UI Flow**: User actions → drawer events → application logic
3. **Query Flow**: Query buffer → execution → result buffer
4. **Connection Flow**: Connection metadata → actual database connection

## 6. Runtime Flow

### 6.1 Initialization Flow

```
1. Plugin loads (plugin/db_ui.vim)
   ↓
2. User executes :DBUI command
   ↓
3. db_ui#open() called
   ↓
4. s:init() creates main dbui instance
   ↓
5. populate_dbs() aggregates connections from:
   - Environment variables
   - Global variables (g:dbs)
   - Connections file
   ↓
6. drawer.open() creates UI buffer
   ↓
7. drawer.render() displays initial state
```

### 6.2 Query Execution Flow

```
1. User selects table/saved query in drawer
   ↓
2. drawer.toggle_line() triggers query.open()
   ↓
3. query.open() creates buffer with appropriate content
   ↓
4. User writes/edits query and saves (:w)
   ↓
5. Autocommand triggers vim-dadbod execution
   ↓
6. Results displayed in .dbout buffer
   ↓
7. dbout.vim provides result-specific functionality
```

### 6.3 Connection Management Flow

```
1. Connection needed for operation
   ↓
2. dbui.connect() called
   ↓
3. If not connected, establish connection via vim-dadbod
   ↓
4. Populate schema information
   ↓
5. Cache connection for future use
```

## 7. Extension Points

### 7.1 Configuration Extension Points

1. **Global Variables**:
   - `g:db_ui_*` variables for behavior customization
   - `g:db_ui_icons` for UI customization
   - `g:db_ui_table_helpers` for custom table operations

2. **Database Sources**:
   - Environment variables with configurable prefixes
   - Global variables (`g:dbs`, `g:db`)
   - JSON connection files
   - Dynamic URL resolution

### 7.2 Functional Extension Points

1. **Schema Support**:
   - Add new database types to `schemas.vim`
   - Custom query templates per database type
   - Result parsing strategies

2. **Table Helpers**:
   - Custom operations per database type
   - User-defined helper functions
   - Auto-execution hooks

3. **UI Customization**:
   - Custom icons and visual elements
   - Drawer section configuration
   - Mapping customization

### 7.3 Integration Extension Points

1. **Autocompletion Integration**:
   - vim-dadbod-completion integration points
   - Custom completion functions

2. **Notification Backends**:
   - Custom notification providers
   - Multiple notification systems

3. **Buffer Management**:
   - Custom buffer name generation
   - Specialized buffer behaviors

### 7.4 Event Hooks

1. **User Events**:
   - `DBUIOpened` - Fired when drawer opens
   - `*DBExecutePre/Post` - Around query execution

2. **Autocommand Hooks**:
   - Buffer creation/destruction
   - Filetype-specific behavior
   - Window management

## 8. Key Design Decisions

### 8.1 Modular Architecture
- Clear separation between UI, business logic, and data access
- Each module has single responsibility
- Loose coupling through well-defined APIs

### 8.2 Configuration Flexibility
- Multiple configuration sources with precedence
- Runtime configuration updates
- Environment-specific configurations

### 8.3 Database Abstraction
- Pluggable database support through schemas module
- Database-specific optimizations
- Unified interface across database types

### 8.4 Buffer Management Strategy
- Automatic buffer lifecycle management
- Context-aware buffer behavior
- Efficient buffer naming and organization

## 9. Technical Considerations

### 9.1 Performance
- Lazy loading of database connections
- Efficient UI rendering with minimal redraws
- Caching of schema information

### 9.2 Compatibility
- Vim 8.1+ and Neovim support
- Cross-platform compatibility
- Backward compatibility considerations

### 9.3 Error Handling
- Comprehensive error reporting through notifications
- Graceful degradation for unsupported features
- Connection error handling and recovery

### 9.4 Testing Strategy
- Themis test framework integration
- Comprehensive test coverage in test/ directory
- Mock-based testing for database operations

## 10. Future Architecture Considerations

### 10.1 Potential Improvements

1. **Async Operations**: Enhanced async support for long-running operations
2. **Plugin System**: More extensible plugin architecture for custom functionality
3. **Configuration Management**: Centralized configuration with validation
4. **Performance Optimization**: Caching strategies and query optimization

### 10.2 Scalability Considerations

1. **Large Dataset Handling**: Pagination and streaming for large results
2. **Connection Pooling**: Efficient connection management for many databases
3. **Memory Management**: Optimized buffer and memory usage

---

*This architecture report provides a comprehensive overview of the vim-dadbod-ui codebase, serving as a reference for developers working with or extending the plugin.*
