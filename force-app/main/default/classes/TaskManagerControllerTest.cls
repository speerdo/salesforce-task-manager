@isTest
public class TaskManagerControllerTest {
  
  @TestSetup
  static void makeData() {
    List<Task_Manager__c> tasks = new List<Task_Manager__c>{
      new Task_Manager__c(
        Name = 'High Priority Task',
        Status__c = 'Not Started',
        Priority__c = 'High',
        Due_Date__c = Date.today().addDays(7),
        Description__c = 'Test description one'
      ),
      new Task_Manager__c(
        Name = 'Medium Priority Task',
        Status__c = 'In Progress',
        Priority__c = 'Medium',
        Due_Date__c = Date.today().addDays(14),
        Description__c = 'Test description two'
      ),
      new Task_Manager__c(
        Name = 'Completed Task',
        Status__c = 'Completed',
        Priority__c = 'Low',
        Due_Date__c = Date.today().addDays(3),
        Description__c = 'Test description three'
      )
    };
    insert tasks;
  }

  @isTest
  static void testGetAllTasks() {
    Test.startTest();
    List<Task_Manager__c> tasks = TaskManagerController.getTasks(null, null);
    Test.stopTest();
    
    Assert.areEqual(3, tasks.size(), 'Should return all 3 tasks when no filters applied');
  }

  @isTest
  static void testGetTasksFilteredByStatus() {
    Test.startTest();
    List<Task_Manager__c> tasks = TaskManagerController.getTasks('In Progress', null);
    Test.stopTest();
    
    Assert.areEqual(1, tasks.size(), 'Should return only In Progress tasks');
    Assert.areEqual('In Progress', tasks[0].Status__c, 'Returned task should have In Progress status');
  }

  @isTest
  static void testGetTasksFilteredByPriority() {
    Test.startTest();
    List<Task_Manager__c> tasks = TaskManagerController.getTasks(null, 'High');
    Test.stopTest();
    
    Assert.areEqual(1, tasks.size(), 'Should return only High priority tasks');
    Assert.areEqual('High', tasks[0].Priority__c, 'Returned task should have High priority');
  }

  @isTest
  static void testGetTasksFilteredByBoth() {
    Test.startTest();
    List<Task_Manager__c> tasks = TaskManagerController.getTasks('Not Started', 'High');
    Test.stopTest();
    
    Assert.areEqual(1, tasks.size(), 'Should return task matching both filters');
  }

  @isTest
  static void testCreateTask() {
    Task_Manager__c newTask = new Task_Manager__c(
      Name = 'Brand New Task',
      Status__c = 'Not Started',
      Priority__c = 'High',
      Due_Date__c = Date.today().addDays(5),
      Description__c = 'Created in test'
    );
    
    Test.startTest();
    Task_Manager__c result = TaskManagerController.saveTask(newTask);
    Test.stopTest();
    
    Assert.isNotNull(result.Id, 'Saved task should have an Id assigned');
    
    Task_Manager__c verify = [SELECT Id, Name, Status__c, Priority__c FROM Task_Manager__c WHERE Id = :result.Id];
    Assert.areEqual('Brand New Task', verify.Name, 'Task name should match');
    Assert.areEqual('High', verify.Priority__c, 'Task priority should match');
  }

  @isTest
  static void testUpdateTask() {
    Task_Manager__c existing = [SELECT Id, Name, Status__c FROM Task_Manager__c WHERE Name = 'High Priority Task' LIMIT 1];
    
    existing.Status__c = 'In Progress';
    
    Test.startTest();
    Task_Manager__c result = TaskManagerController.saveTask(existing);
    Test.stopTest();
    
    Task_Manager__c verify = [SELECT Id, Status__c FROM Task_Manager__c WHERE Id = :existing.Id];
    Assert.areEqual('In Progress', verify.Status__c, 'Status should be updated to In Progress');
  }

  @isTest
  static void testDeleteTask() {
    Task_Manager__c existing = [SELECT Id FROM Task_Manager__c WHERE Name = 'Completed Task' LIMIT 1];
    
    Test.startTest();
    TaskManagerController.deleteTask(existing.Id);
    Test.stopTest();
    
    List<Task_Manager__c> verify = [SELECT Id FROM Task_Manager__c WHERE Id = :existing.Id];
    Assert.areEqual(0, verify.size(), 'Deleted task should no longer exist in database');
  }

  @isTest
  static void testGetTasksNoResults() {
    Test.startTest();
    List<Task_Manager__c> tasks = TaskManagerController.getTasks('Blocked', null);
    Test.stopTest();
    
    Assert.areEqual(0, tasks.size(), 'Should return empty list when no tasks match filter');
  }
}