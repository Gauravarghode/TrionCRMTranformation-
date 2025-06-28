public class Arch_ScheduleUploadSecondValidationBatch implements Schedulable  {
    
       public void execute(SchedulableContext sc){
        Arch_UploadSecondValidationBatch uvb = new Arch_UploadSecondValidationBatch();
        Database.executeBatch(uvb, 1);
    }

}