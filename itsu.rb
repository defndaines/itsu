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

  # Determine if a time falls within the current period.
  # For example, if the period is 'week', then check if the date falls within
  # the current week.
  # This can be used to test if a occurrence has already happened this period.
  # For weeks, consider the week to start on Monday.
  #
  # @param [DateTime] time Timestamp to check.
  # @param [Itsu::Period] period Period to check against.
  # @return [Boolean] Whether the timestamp is within the most recent period.
  #
  def in_period?(time, period)
    now = Time.now
    case period
    when Period::WEEK
      # Check relative to time.wday >= 1
    when Period::MONTH
      if time.year == now.year
        time.month == now.month
      else
        false
      end
    when Period::QUARTER
      # Every three months.
    else
      raise ArgumentError, "Unrecognized period, #{period}."
    end
  end
end
