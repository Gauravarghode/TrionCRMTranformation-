global class Arch_RetrySchedulableSharePointCSV implements Schedulable{

    String status;
    global Arch_RetrySchedulableSharePointCSV(String status){
        this.status = status;
    }
    
    global void execute(SchedulableContext sc){
        System.abortJob(sc.getTriggerId());
        
        Datetime now = Datetime.now();
        Datetime nextRun = now.addMinutes(3);
 
        String cronExp = nextRun.second() + ' ' + nextRun.minute() + ' ' +  now.hour() + ' ' + ' * ' + ' ' + ' * ' + ' ? ' + ' * ';
        System.schedule('Arch_Retry Schedulable SharePoint CSV Upload -' + nextRun.getTime(), cronExp, new Arch_RetrySchedulableSharePointCSV(status));
        database.executeBatch(new Arch_RetrySharePointEmailBatchCSV(status), 500);
    }
}