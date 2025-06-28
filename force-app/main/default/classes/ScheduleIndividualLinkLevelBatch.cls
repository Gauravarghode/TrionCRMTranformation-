global class ScheduleIndividualLinkLevelBatch implements Schedulable  {
    
    global void execute(SchedulableContext ctx){
         
         IndividualLinkLevelDetailsBatchHandler invidualEmailResultsBatchHandler = new IndividualLinkLevelDetailsBatchHandler();
         Database.executebatch(invidualEmailResultsBatchHandler, 200);
         
     }

}