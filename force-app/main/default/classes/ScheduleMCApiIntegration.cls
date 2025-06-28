public class ScheduleMCApiIntegration Implements Schedulable {

    public void execute(SchedulableContext sc){
        makeCallout();
    }
    
    @future(callout = true)
    public static void makeCallout(){
         McApiIntegration.createEmailTemplatesAndCtas();
    }
}