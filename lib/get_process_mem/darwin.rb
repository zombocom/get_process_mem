require 'ffi'

class GetProcessMem
  class Darwin
    extend FFI::Library
    ffi_lib 'c'
    attach_function :mach_task_self, [], :__darwin_mach_port_t
    attach_function :task_info,
                    [
                      :__darwin_mach_port_t,
                      :int,     # return selector
                      :pointer, #pointer to task info
                      :pointer, #pointer to int (size of structure / bytes filled out)
                    ],
                    :int

    class IntPtr < FFI::Struct
      layout :value, :int
    end

    class TaskInfo < FFI::Struct
      layout  :suspend_count, :int32,
              :virtual_size, :uint64,
              :resident_size, :uint64,
              :user_time, :uint64,
              :system_time, :uint64,
              :policy, :int32
    end

    MACH_TASK_BASIC_INFO = 20
    MACH_TASK_BASIC_INFO_COUNT = TaskInfo.size / FFI.type_size(:uint)

    class << self
      def resident_size
        mach_task_info[:resident_size]
      end

      private

      def mach_task_info
        data = TaskInfo.new
        out_count = IntPtr.new
        out_count[:value] = MACH_TASK_BASIC_INFO_COUNT
        result = task_info(mach_task_self, MACH_TASK_BASIC_INFO, data, out_count)
        if result == 0
          data
        else
          raise "task_info returned #{result}"
        end
      end
    end
  end
end
