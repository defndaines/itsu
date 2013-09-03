#!/usr/bin/env ruby

# Simple Time checking library.
# The goal is to check on regularly occurring events in a business cycle,
# such as something that needs to happen every week, month, or quarter.
# 
# All time math is done relative to the time zone of the supplied argument.
#
module Itsu
  module_function

  # Supported period constants
  #
  module Period
    WEEK = 'week'
    MONTH = 'month'
    QUARTER = 'quarter'
  end

  SECONDS_IN_HOUR = 3600
  SECONDS_IN_DAY = 86400

  # Roll back the time to the beginning of the day (midnight, 00:00:00)
  #
  # @param [Time] time Timestamp
  # @return [Time] Timestamp of the start of the day.
  # 
  def start_of_day(time)
    day = time - time.hour * SECONDS_IN_HOUR
    day -= time.min * 60
    day -= time.sec
    _adjust_dst(day)
  end

  # Get the starting time for the first day of the week (Monday) relative to
  # the provided timestamp.
  # If the timestamp is on Monday, will return the start of the same day.
  #
  # @param [Time] time Timestamp
  # @return [Time] Timestamp of the previous Monday.
  #
  def start_of_week(time)
    mon = time - ((time.wday + 6) % 7 * SECONDS_IN_DAY)
    start_of_day(mon)
  end

  # Roll back the time to the beginning of the month.
  #
  # @param [Time] time Timestamp
  # @return [Time] Timestamp of the start of the month.
  # 
  def start_of_month(time)
    first = time - (time.mday - 1) * SECONDS_IN_DAY
    start_of_day(first)
  end

  # Get the starting time for the first day of the quarter relative to the
  # provided timestamp.
  #
  # @param [Time] time Timestamp
  # @return [Time] Timestamp of the start of the quarter.
  #
  def start_of_quarter(time)
    back = (time.mon - 1) % 3
    qtr = time
    (1..back).each { qtr -= qtr.mday * SECONDS_IN_DAY }
    start_of_month(qtr)
  end

  # Determine if a time falls within the current period.
  # For example, if the period is 'week', then check if the date falls within
  # the current week.
  # This can be used to test if a occurrence has already happened this period.
  # For weeks, consider the week to start on Monday.
  # This is a history check. All future times will return true.
  #
  # @param [Time] time Timestamp to check.
  # @param [Itsu::Period] period Period to check against.
  # @return [Boolean] Whether the timestamp is within the most recent period.
  #
  def in_period?(time, period)
    case period
    when Period::WEEK
      time > start_of_week(Time.now)
    when Period::MONTH
      time > start_of_month(Time.now)
    when Period::QUARTER
      time > start_of_quarter(Time.now)
    else
      raise ArgumentError, "Unrecognized period, #{period}."
    end
  end

  def _adjust_dst(time)
    # Internal method. Assumes midnight adjustments have already occurred.
    case time.hour
    when 0
      time
    when 1
      time - SECONDS_IN_HOUR
    when 23
      time + SECONDS_IN_HOUR
    end
  end
end
