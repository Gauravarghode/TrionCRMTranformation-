public class Arch_ScheduleUploadValidationBatch implements Schedulable{
    
    public void execute(SchedulableContext sc){
        Arch_UploadValidationBatch uvb = new Arch_UploadValidationBatch();
        Database.executeBatch(uvb, 1);
    }
    
}