
def rate_limiter(action_count, actions_per_second, action_name)
  actions_completed_this_second = 0
  actions_completed = 0
  start_time = Time.now
  while actions_completed < action_count
    if actions_completed_this_second < actions_per_second
      yield(actions_completed)
      actions_completed += 1
      actions_completed_this_second += 1
    else
      time_elapsed_to_complete_actions = Time.now - start_time
      actual_cps = actions_completed_this_second / time_elapsed_to_complete_actions

      # sleep enough to stay below our actions per second (APS) target
      delay_to_stay_below_target_aps = 1 - time_elapsed_to_complete_actions
      if delay_to_stay_below_target_aps > 0
        puts("Actual #{action_name}: #{actual_cps.round(1)}. Target #{action_name}: #{actions_per_second}. Sleeping #{(delay_to_stay_below_target_aps*1000).round(0)}ms to stay below target.")
        sleep(delay_to_stay_below_target_aps)
      else
        # not able to hit target APS, print warning
        puts("Actual #{action_name}: #{actual_cps.round(1)}. Target #{action_name}: #{actions_per_second}")
      end

      # reset the aps counter and timer
      actions_completed_this_second = 0
      start_time = Time.now
    end
  end
end
