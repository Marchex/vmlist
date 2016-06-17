
# Monkey patch Numeric class method to return percent
class Numeric
  def percent_of(n)
    self.to_f / n.to_f * 100.00
  end
end
module VmList
  class KvmHost
    attr_accessor :cpu_total
    attr_accessor :guest_cpu_total
    attr_accessor :cpu_percentage
    attr_accessor :cpu_color
    attr_accessor :memory
    attr_accessor :guest_maxmem_total
    attr_accessor :mem_percentage
    attr_accessor :mem_color
    attr_accessor :platform
    attr_accessor :platform_version
    attr_accessor :platform_color
    attr_accessor :use
    attr_accessor :use_color
    attr_accessor :guests


    def initialize(data)
      # the magic strings in the data structure have to map to what is used in the
      # partial_search in the VmList::Server object.
      self.cpu_total          = data['cpu_total'].to_i || 0
      self.guest_cpu_total    = data['guest_cpu_total'].to_i || 0
      self.memory             = data['memory'].to_i/1048576
      self.guest_maxmem_total = data['guest_maxmem_total'].to_i/1048576
      self.platform           = data['platform'].to_s
      self.platform_version   = data['platform_version'].to_s
      self.use                = data['use'].nil? || data['use'].empty? ? 'unknown' : data['use'].to_s
      self.guests             = data['guests']

    end

    def finalize
      self.cpu_percentage     = (self.guest_cpu_total).percent_of(self.cpu_total).round(2)
      self.mem_percentage     = (self.guest_maxmem_total).percent_of(self.memory).round(2)
      calculate_cpu_color
      calculate_use_color
      calculate_platform_color
      calculate_memory_color
    end

    def calculate_cpu_color
      s = self

      if s.cpu_percentage < 100
        cpushade = '%02x' % ((100 - (s.cpu_percentage))*2.55)
        s.cpu_color = cpushade + 'FF' + cpushade
      elsif s.cpu_percentage < 130
        s.cpu_color = '00FF00'
      elsif s.cpu_percentage < 258
        cpuover = s.cpu_percentage - 130
        cpured = '%02x' % (2 * cpuover)
        cpugreen = '%02x' % (255 - (2 * cpuover))
        cpublue = '%02x' % ((0.5 * cpuover).round)
        s.cpu_color = cpured + cpugreen + cpublue
      else
        s.cpu_color = 'FF0000'
      end
    end
    
    def calculate_use_color
      self.use_color =
          case self.use
            when 'broken' then
              'FF4040'
            when 'corp' then
              'D2B48C'
            when 'ghetto' then
              'COCO60'
            when 'infrastructure' then
              'FF8020'
            when 'lab' then
              '8080FF'
            when 'production' then
              '40FF40'
            when 'preprod' then
              'FFFFFF'
            when 'special' then
              'FFFF40'
            when 'database' then
              'CCAA10'
            else
              'C0C0C0'
          end
    end
    
    def calculate_platform_color
      s = self
      if  s.platform == 'centos' && s.platform_version == '6.6'
        s.platform_color = '50FF50'
      elsif s.platform == 'centos' && s.platform_version == '6.5'
        s.platform_color  = 'FFFF40'
      elsif s.platform == 'centos' && s.platform_version == '6.4'
        s.platform_color  = 'FFEE40'
      elsif s.platform == 'centos' && s.platform_version == '7.1.1503'
        s.platform_color  = '00FF00'
      else
        s.platform_color  = 'FF4040'
      end
    end
    
    def calculate_memory_color
      s = self
      if s.mem_percentage < 100
        memshade = '%02x' % ((100 - (s.mem_percentage))*2.55)
        s.mem_color = memshade + 'FF' + memshade
      elsif s.mem_percentage < 228
        memover = s.mem_percentage - 100
        memred = '%02x' % (2 * memover)
        memgreen = '%02x' % (255 - (2 * memover))
        memblue = '%02x' % ((0.5 * memover).round)
        s.mem_color = memred + memgreen + memblue
      else
        s.mem_color = 'FF0000'
      end
    end

  end
end