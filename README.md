# Salesforce Task Manager

A custom Salesforce application built to demonstrate Apex and Lightning Web Component development skills. Built using modern Salesforce DX tooling with source-tracked metadata, full CRUD functionality, and comprehensive test coverage.

## Features

- Create, read, update, and delete custom Task Manager records
- Filter tasks by status and priority using dynamic SOQL
- Clean Lightning Web Component UI built with the latest LWC framework
- 82% Apex test coverage across 8 test methods (exceeds 80% production deployment requirement)
- Full source-tracked metadata deployable via Salesforce CLI

## Technical Stack

- **Apex** - server-side business logic and data operations with `with sharing` security model
- **SOQL** - dynamic queries with conditional WHERE clauses and NULLS LAST ordering
- **Lightning Web Components** - modern component-based UI framework
- **Salesforce Object Model** - custom object with picklist, date, and long text area field types
- **Salesforce CLI (sf)** - source-tracked deployment and scratch org development

## Project Structure

```
force-app/main/default/
├── objects/
│   └── Task_Manager__c/
│       ├── Task_Manager__c.object-meta.xml
│       └── fields/
│           ├── Status__c.field-meta.xml
│           ├── Priority__c.field-meta.xml
│           ├── Due_Date__c.field-meta.xml
│           └── Description__c.field-meta.xml
├── classes/
│   ├── TaskManagerController.cls
│   ├── TaskManagerController.cls-meta.xml
│   ├── TaskManagerControllerTest.cls
│   └── TaskManagerControllerTest.cls-meta.xml
└── lwc/
    └── taskManager/
        ├── taskManager.html
        ├── taskManager.js
        └── taskManager.js-meta.xml
```

## Setup Instructions

### Prerequisites

- [Salesforce CLI](https://developer.salesforce.com/tools/salesforcecli) installed
- A Salesforce Developer Edition org with Dev Hub enabled
- VS Code with the [Salesforce Extension Pack](https://marketplace.visualstudio.com/items?itemName=salesforce.salesforcedx-vscode)

### Steps

**1. Clone the repository**
```bash
git clone https://github.com/speerdo/salesforce-task-manager.git
cd salesforce-task-manager
```

**2. Authorize your Dev Hub**
```bash
sf org login web --alias my-devhub --set-default-dev-hub
```

**3. Create a scratch org**
```bash
sf org create scratch \
  --definition-file config/project-scratch-def.json \
  --alias task-manager-scratch \
  --set-default \
  --duration-days 30
```

**4. Deploy the metadata**
```bash
sf project deploy start --source-dir force-app --target-org task-manager-scratch
```

**5. Run tests**
```bash
sf apex run test --target-org task-manager-scratch --code-coverage --result-format human
```

**6. Open the org**
```bash
sf org open --target-org task-manager-scratch
```

## Code Highlights

### Dynamic SOQL with Conditional Filtering (`TaskManagerController.cls`)

Rather than writing separate query methods for each filter combination, `getTasks` builds the WHERE clause dynamically based on which parameters are passed. This keeps the controller lean and handles all four filter states: no filter, status only, priority only, and both in a single method.

```java
@AuraEnabled(cacheable=true)
public static List<Task_Manager__c> getTasks(String statusFilter, String priorityFilter) {
    String query = 'SELECT Id, Name, Status__c, Priority__c, Due_Date__c, Description__c ' +
                   'FROM Task_Manager__c ';
    List<String> conditions = new List<String>();
    if (String.isNotBlank(statusFilter)) {
        conditions.add('Status__c = :statusFilter');
    }
    if (String.isNotBlank(priorityFilter)) {
        conditions.add('Priority__c = :priorityFilter');
    }
    if (!conditions.isEmpty()) {
        query += 'WHERE ' + String.join(conditions, ' AND ');
    }
    query += ' ORDER BY Due_Date__c ASC NULLS LAST';
    return Database.query(query);
}
```

### Upsert for Create and Update (`TaskManagerController.cls`)

A single `saveTask` method handles both creating new records and updating existing ones using Salesforce's `upsert` DML statement. If the record has an Id it updates, if not it inserts. This means the LWC only needs to call one method regardless of context.

### `@TestSetup` for Efficient Test Data (`TaskManagerControllerTest.cls`)

Test data is created once using `@TestSetup` and snapshotted by the platform. Each test method receives its own isolated copy, which is faster than creating data inside every individual test and keeps the test class clean.

## Test Coverage

| Class | Coverage |
|---|---|
| TaskManagerController | 82% |
| Org Wide | 81% |

All 8 test methods pass. The 4 uncovered lines are `catch` block exception handlers in `saveTask` and `deleteTask` — paths that require specific DML failures to trigger, which are difficult to produce reliably without dedicated validation rules.

## Lessons Learned

Coming back to Salesforce development after a couple of years, a few things stood out.

The `with sharing` vs `without sharing` distinction matters more than I remembered. It's easy to write `without sharing` and move on, but doing so silently bypasses the platform's entire record-level security model. Defaulting to `with sharing` is the correct and safer choice for any user-facing component.

The `@AuraEnabled(cacheable=true)` annotation is only valid on read methods — you cannot cache a method that performs DML. This is enforced at runtime, not compile time, so it's the kind of thing that surfaces as a confusing error if you don't understand why the restriction exists.

Salesforce's test isolation model is genuinely well designed. The automatic transaction rollback after each test means you can run destructive DML operations freely without any cleanup logic. Combined with `@TestSetup`, writing thorough test coverage feels less like overhead than it does in other frameworks.

## Why I Built This

I worked with Salesforce development from 2021 to 2023 and wanted to rebuild fluency with the current tooling, specifically the modern `sf` CLI, source-tracked scratch org development, and the latest LWC patterns. This project covers the full development loop from metadata creation through Apex business logic, test coverage, and component-based UI.