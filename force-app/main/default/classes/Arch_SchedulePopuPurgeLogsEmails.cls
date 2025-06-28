global class Arch_SchedulePopuPurgeLogsEmails implements Schedulable {

    global void execute(SchedulableContext sc){
        database.executeBatch(new Arch_PopuPurgeLogsEmails(), 500);
    }
}