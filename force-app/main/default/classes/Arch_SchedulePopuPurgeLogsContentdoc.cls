global class Arch_SchedulePopuPurgeLogsContentdoc implements Schedulable {
    
    global void execute(SchedulableContext sc){
        database.executeBatch(new Arch_PopuPurgeLogsContentdoc(), 500);
    }
}