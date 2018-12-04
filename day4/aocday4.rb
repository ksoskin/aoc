#!/usr/bin/env ruby

require 'pp'
require 'time'
require 'benchmark'

puts Benchmark.measure {
@input = File.readlines('inputday4.log').sort

def go_through_log(log, hash={})
  log.each do |line|
    ts, info = line.split('] ')
    ts = ts.gsub('[','').gsub(' ', 'T')
    case info
    when/^Guard/
      @current_guard = info.split(' ')[0..1].join(' ')
      hash[@current_guard] ||= []
    when /^falls/ 
      @start_time = ts
    when /^wakes/
      startt = Time.parse(@start_time)
      endt = Time.parse(ts)
      delta = (endt.to_i - startt.to_i)
      mins_between = []
      while startt < endt
       mins_between << startt.min
       startt += 60
      end
      hash[@current_guard] << {delta: delta, mins_between: mins_between}
    end
  end
  return hash
end

def part_1
  parsed = go_through_log(@input)
  guard_with_most_sleep = parsed.max_by {|k,v| v.map {|h| h[:delta]}.inject(0) {|sum,x| sum + x }}
  all_mins = guard_with_most_sleep[1].map {|h| h[:mins_between]}.flatten
  most_occuring_min = all_mins.group_by(&:itself).values.max_by(&:size).first.to_i
  guard_num = guard_with_most_sleep[0].split('#').last.to_i
  pp [guard_num, most_occuring_min, guard_num * most_occuring_min]
end


def part_2
  p2hash = {}
  @most_freq_guard, @highest_freq = nil, 0
  parsed = go_through_log(@input)
  parsed.each do |guard, sleeps|
     next if sleeps.size <= 1
     p2hash[guard] ||= {}
     sleeps.each do |sleep|
      sleep[:mins_between].each do |sleep_min|
        p2hash[guard][sleep_min] ||= 0
        p2hash[guard][sleep_min] += 1
        if p2hash[guard][sleep_min] > @highest_freq 
          @highest_freq = p2hash[guard][sleep_min]
          @most_freq_guard = guard
        end
      end
    end
  end
  g = @most_freq_guard.split(?#)[1].to_i
  pp [g, @highest_freq, g * @highest_freq] 
end

ARGV[0] == ?a  ? part_1 : part_2
}
