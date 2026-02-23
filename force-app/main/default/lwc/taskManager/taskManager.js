import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { refreshApex } from '@salesforce/apex';
import getTasks from '@salesforce/apex/TaskManagerController.getTasks';
import saveTask from '@salesforce/apex/TaskManagerController.saveTask';
import deleteTask from '@salesforce/apex/TaskManagerController.deleteTask';

export default class TaskManager extends LightningElement {

  @track tasks = [];
  @track selectedTask = {};
  @track isModalOpen = false;
  @track statusFilter = '';
  @track priorityFilter = '';
  
  wiredTasksResult;

  @wire(getTasks, { 
    statusFilter: '$statusFilter', 
    priorityFilter: '$priorityFilter' 
  })
  wiredTasks(result) {
    this.wiredTasksResult = result;
    if (result.data) {
      this.tasks = result.data;
    } else if (result.error) {
      this.showToast('Error', result.error.body.message, 'error');
    }
  }

  get hasNoTasks() {
    return this.tasks.length === 0;
  }

  get statusOptions() {
    return [
      { label: 'All', value: '' },
      { label: 'Not Started', value: 'Not Started' },
      { label: 'In Progress', value: 'In Progress' },
      { label: 'Completed', value: 'Completed' },
      { label: 'Blocked', value: 'Blocked' }
    ];
  }

  get priorityOptions() {
    return [
      { label: 'All', value: '' },
      { label: 'High', value: 'High' },
      { label: 'Medium', value: 'Medium' },
      { label: 'Low', value: 'Low' }
    ];
  }

  get modalTitle() {
    return this.selectedTask.Id ? 'Edit Task' : 'New Task';
  }

  get columns() {
    return [
      { label: 'Task Name', fieldName: 'Name', type: 'text' },
      { label: 'Status', fieldName: 'Status__c', type: 'text' },
      { label: 'Priority', fieldName: 'Priority__c', type: 'text' },
      { label: 'Due Date', fieldName: 'Due_Date__c', type: 'date' },
      { label: 'Description', fieldName: 'Description__c', type: 'text', wrapText: true },
      {
        type: 'action',
        typeAttributes: {
          rowActions: [
            { label: 'Edit', name: 'edit' },
            { label: 'Delete', name: 'delete' }
          ]
        }
      }
    ];
  }

  handleRowAction(event) {
    const actionName = event.detail.action.name;
    const row = event.detail.row;

    if (actionName === 'edit') {
      this.handleEditTask({ detail: row });
    } else if (actionName === 'delete') {
      this.handleDeleteTask({ detail: row.Id });
    }
  }

  handleStatusFilterChange(event) {
    this.statusFilter = event.target.value;
  }

  handlePriorityFilterChange(event) {
    this.priorityFilter = event.target.value;
  }

  handleNewTask() {
    this.selectedTask = {};
    this.isModalOpen = true;
  }

  handleEditTask(event) {
    this.selectedTask = { ...event.detail };
    this.isModalOpen = true;
  }

  handleFieldChange(event) {
    const field = event.target.fieldName || event.target.name;
    this.selectedTask = { 
      ...this.selectedTask, 
      [field]: event.target.value 
    };
  }

  handleSaveTask() {
    if (!this.selectedTask.Name) {
      this.showToast('Error', 'Task name is required', 'error');
      return;
    }
    
    saveTask({ task: this.selectedTask })
      .then(() => {
        this.showToast('Success', 'Task saved successfully', 'success');
        this.isModalOpen = false;
        this.selectedTask = {};
        return refreshApex(this.wiredTasksResult);
      })
      .catch(error => {
        this.showToast('Error', error.body.message, 'error');
      });
}

  handleDeleteTask(event) {
    const taskId = event.detail;
    
    deleteTask({ taskId })
      .then(() => {
        this.showToast('Success', 'Task deleted successfully', 'success');
        return refreshApex(this.wiredTasksResult);
      })
      .catch(error => {
        this.showToast('Error', error.body.message, 'error');
      });
  }

  handleCloseModal() {
    this.isModalOpen = false;
    this.selectedTask = {};
  }

  showToast(title, message, variant) {
    this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
  }
}