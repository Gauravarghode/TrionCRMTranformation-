public class Arch_ScheduleConvertCSVPopulateTable implements Schedulable {
    
    public void execute(SchedulableContext context) {
        Arch_ConvertCSVPopulateTable batchtocsvBatch = New Arch_ConvertCSVPopulateTable();
        Database.executeBatch(batchtocsvBatch, 1);    
    }
}