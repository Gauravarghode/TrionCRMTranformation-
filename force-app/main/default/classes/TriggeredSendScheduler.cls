global class TriggeredSendScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        TriggeredSendService.deactivateSendOfOldestCampaign();
    }
}