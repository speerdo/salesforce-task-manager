public with sharing class TaskManagerController {

	@AuraEnabled(cacheable=true)
	public static List<Task_Manager__c> getTasks(String statusFilter, String priorityFilter) {
		String query = 'SELECT Id, Name, Status__c, Priority__c, Due_Date__c, Description__c ' + 'FROM Task_Manager__c ';
		
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

	@AuraEnabled
	public static Task_Manager__c saveTask(Task_Manager__c task) {
		try {
			upsert task;
			return task;
		} catch (DmlException e) {
			throw new AuraHandledException(e.getMessage());
		}
	}

	@AuraEnabled
	public static void deleteTask(Id taskId) {
		try {
			delete [SELECT Id FROM Task_Manager__c WHERE Id = :taskId];
		} catch (DmlException e) {
			throw new AuraHandledException(e.getMessage());
		}
	}
}