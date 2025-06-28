global class Arch_RetrySchedulableSharePointFA implements Schedulable {
    
    String status;
    global Arch_RetrySchedulableSharePointFA(String status){
        this.status = status;
    }
    
    global void execute(SchedulableContext sc){
       	
        System.abortJob(sc.getTriggerId());
        
        Datetime now = Datetime.now();
        Datetime nextRun = now.addMinutes(3);
 
        String cronExp = nextRun.second() + ' ' + nextRun.minute() + ' ' +  now.hour() + ' ' + ' * ' + ' ' + ' * ' + ' ? ' + ' * ';
        System.schedule('Arch_Retry Schedulable SharePoint Files & Attachments Upload -' + nextRun.getTime(), cronExp, new Arch_RetrySchedulableSharePointFA(status));
        
        database.executeBatch(new Arch_RetrySharePointStagingBatchFA(status), 500);
    }
}