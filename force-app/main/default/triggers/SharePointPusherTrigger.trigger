trigger SharePointPusherTrigger on SharePointPusher__e (after insert) {
    if(trigger.isInsert&& trigger.isAfter){
        SharePointPusherHandler.subscribeEvents(trigger.new);

    }

}