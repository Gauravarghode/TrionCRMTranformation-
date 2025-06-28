global class ScheduleBatchToUpdateCMStatus implements Schedulable{
     global void execute(SchedulableContext SC) {
      BatchToUpdateCMStatus updateCMS = new BatchToUpdateCMStatus(); 
      Database.executeBatch(updateCMS);
 
         
   }
 
}