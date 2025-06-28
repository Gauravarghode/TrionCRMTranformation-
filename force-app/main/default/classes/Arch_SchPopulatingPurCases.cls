global class Arch_SchPopulatingPurCases implements Schedulable {
  
  
    
    global void execute(SchedulableContext sc){
        database.executeBatch(new Arch_PopulatingPurgeCases(), 500);
    }
}