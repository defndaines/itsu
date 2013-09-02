#!/usr/bin/env ruby
require 'time'

# Simple date and schedule parsing library.
# The goal is to check on regularly occurring events in a business cycle,
# such as something that needs to happen every week, month, or quarter.
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

  SECONDS_IN_DAY = 86400

  # Parse a duration string. Only support hours and minutes in the format: #h#m
  # Converts values to seconds, since Ruby date math works is seconds.
  #
  # @param [String] duration Duration value to parse.
  # @return [Fixnum] number of seconds represented by the duration.
  #
  def parse_duration(duration)
    match = /(\d*)h?(\d*)m?/.match(duration)
    dur= match[2].to_i
    dur += 60 * match[1].to_i
    dur * 60
  end

  # Roll back the time to the beginning of the day (0:00:00)
  #
  # @param [Time] time Timestamp
  # @return [Time] Timestamp of the start of the day.
  # 
  def start_of_day(time)
    day = time - time.hour * 60 * 60
    day -= time.min * 60
    day -= time.sec
  end

  # Get the starting time for the last Monday relative to the provided
  # timestamp.
  # Will keep time in same time zone.
  # If the timestamp is on Monday, will return the start of the same day.
  #
  # @param [Time] time Timestamp
  # @return [Time] Timestamp of the previous Monday.
  #
  def last_monday(time)
    mon = time - ((time.wday + 6) % 7 * SECONDS_IN_DAY)
    start_of_day(mon)
  end

  # Roll back the time to the beginning of the month.
  #
  # @param [Time] time Timestamp
  # @return [Time] Timestamp of the start of the month.
  # 
  def start_of_month(time)
    first = start_of_day(time)
    first - (first.mday - 1) * SECONDS_IN_DAY
  end

  # Get the starting time for the first day of the quarter relative to the
  # provided timestamp.
  # Will keep time in same time zone.
  #
  # @param [Time] time Timestamp
  # @return [Time] Timestamp of the start of the quarter.
  #
  def start_of_quarter(time)
    back = time.mon % 3
    qtr = time
    (1..back).each { qtr -= qtr.mday * SECONDS_IN_DAY }
    qtr = start_of_month(qtr)
    # Handle crossing daylight savings.
    qtr += ((24 - qtr.hour) % 24) * 60 * 60 unless qtr.hour == 0
    qtr
  end

  # Determine if a time falls within the current period.
  # For example, if the period is 'week', then check if the date falls within
  # the current week.
  # This can be used to test if a occurrence has already happened this period.
  # For weeks, consider the week to start on Monday.
  #
  # @param [Time] time Timestamp to check.
  # @param [Itsu::Period] period Period to check against.
  # @return [Boolean] Whether the timestamp is within the most recent period.
  #
  def in_period?(time, period)
    case period
    when Period::WEEK
      time > last_monday(Time.now)
    when Period::MONTH
      time > start_of_month(Time.now)
    when Period::QUARTER
      time > start_of_quarter(Time.now)
    else
      raise ArgumentError, "Unrecognized period, #{period}."
    end
  end
end
