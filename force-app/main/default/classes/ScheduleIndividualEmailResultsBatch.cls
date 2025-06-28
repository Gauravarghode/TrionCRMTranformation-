Global class ScheduleIndividualEmailResultsBatch implements Schedulable { 

     global void execute(SchedulableContext ctx){
         
         InvidualEmailResultsBatchHandler invidualEmailResultsBatchHandler = new InvidualEmailResultsBatchHandler();
         Database.executebatch(invidualEmailResultsBatchHandler, 200);
         
     }
}