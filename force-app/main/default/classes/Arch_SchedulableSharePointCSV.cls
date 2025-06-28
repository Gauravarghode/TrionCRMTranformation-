global class Arch_SchedulableSharePointCSV implements Schedulable {
    
    String status;
    global Arch_SchedulableSharePointCSV(String status){
        this.status = status;
    }

    global void execute(SchedulableContext sc){
        
        System.abortJob(sc.getTriggerId());
        
        Datetime now = Datetime.now();
        Datetime nextRun = now.addMinutes(3);
        String cronExp = nextRun.second() + ' ' + nextRun.minute() + ' ' +  now.hour() + ' ' + ' * ' + ' ' + ' * ' + ' ? ' + ' * ';
        System.schedule('Arch_Schedulable SharePoint CSV Upload -' + nextRun.getTime(), cronExp, new Arch_SchedulableSharePointCSV(status));
        
        Database.executeBatch(new Arch_SharePointEmailBatchCSV(status), 500);
    }
}