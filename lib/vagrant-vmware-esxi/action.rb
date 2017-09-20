require 'vagrant/action/builder'

module VagrantPlugins
  module ESXi
    # actions and how to run them
    module Action
      include Vagrant::Action::Builtin
      def self.action_connect_esxi
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConnectESXi
        end
      end

      def self.action_read_state
        Vagrant::Action::Builder.new.tap do |b|
          b.use ReadSSHInfo
          b.use ReadState
        end
      end

      def self.action_read_ssh_info
        Vagrant::Action::Builder.new.tap do |b|
          b.use ReadSSHInfo
        end
      end

      def self.action_halt
        Vagrant::Action::Builder.new.tap do |b|
          b.use ReadState
          b.use Halt
        end
      end

      def self.action_suspend
        Vagrant::Action::Builder.new.tap do |b|
          b.use ReadState
          b.use Suspend
        end
      end

      def self.action_resume
        Vagrant::Action::Builder.new.tap do |b|
          b.use ReadState
          b.use Resume
        end
      end

      def self.action_ssh
        Vagrant::Action::Builder.new.tap do |b|
          b.use ReadState
          b.use ReadSSHInfo
          b.use SSHExec
          b.use SSHRun
        end
      end

      def self.action_snapshot_list
        Vagrant::Action::Builder.new.tap do |b|
          b.use SnapshotList
        end
      end

      def self.action_snapshot_info
        Vagrant::Action::Builder.new.tap do |b|
          b.use SnapshotInfo
        end
      end

      def self.action_snapshot_save
        Vagrant::Action::Builder.new.tap do |b|
          b.use SnapshotSave
        end
      end

      def self.action_snapshot_restore
        Vagrant::Action::Builder.new.tap do |b|
          b.use action_halt
          b.use Call, WaitForState, :powered_off, 240 do |env1, b1|
            if env1[:result] == 'True'
              b1.use SnapshotRestore
              b1.use action_up
            end
          end
        end
      end

      def self.action_snapshot_delete
        Vagrant::Action::Builder.new.tap do |b|
          b.use SnapshotDelete
        end
      end


      def self.action_destroy
        Vagrant::Action::Builder.new.tap do |b|
          b.use Call, ReadState do |env1, b1|
            unless env1[:machine_state] == 'powered_off'
              b1.use action_halt
            end
            b1.use ReadState
            b1.use Destroy
          end
        end
      end

      def self.action_reload
        Vagrant::Action::Builder.new.tap do |b|
          b.use Call, ReadState do |env1, b1|
            if (env1[:machine_state].to_s == 'powered_on') ||
               (env1[:machine_state].to_s == 'running') ||
               (env1[:machine_state].to_s == 'suspended')
              b1.use action_halt
            end
            b1.use action_up
          end
        end
      end

      def self.action_up
        Vagrant::Action::Builder.new.tap do |b|
          b.use ConfigValidate
          b.use ConnectESXi
          b.use HandleBox
          b.use ReadState
          b.use CreateVM
          b.use ReadState
          b.use Boot
          b.use Call, WaitForState, :running, 240 do |env1, b1|
            if env1[:result] == 'True'
              b1.use action_provision
            end
          end
        end
      end

      def self.action_provision
        Vagrant::Action::Builder.new.tap do |b|
          b.use ReadState
          b.use Call, WaitForState, :running, 240 do |env1, b1|
            if env1[:result] == 'True'
              b1.use ReadState
              b1.use Provision
              b1.use SyncedFolderCleanup
              b1.use SyncedFolders
            end
          end
        end
      end

      def self.action_package
        Vagrant::Action::Builder.new.tap do |b|
          b.use ReadState
          b.use Package
        end
      end

      action_root = Pathname.new(File.expand_path('../action', __FILE__))
      autoload :ConnectESXi, action_root.join('connect_esxi')
      autoload :CreateVM, action_root.join('createvm')
      autoload :ReadState, action_root.join('read_state')
      autoload :ReadSSHInfo, action_root.join('read_ssh_info')
      autoload :Boot, action_root.join('boot')
      autoload :Halt, action_root.join('halt')
      autoload :Destroy, action_root.join('destroy')
      autoload :Suspend, action_root.join('suspend')
      autoload :Resume, action_root.join('resume')
      autoload :Package, action_root.join('package')
      autoload :SnapshotInfo, action_root.join('snapshot_info')
      autoload :SnapshotList, action_root.join('snapshot_list')
      autoload :SnapshotSave, action_root.join('snapshot_save')
      autoload :SnapshotDelete, action_root.join('snapshot_delete')
      autoload :SnapshotRestore, action_root.join('snapshot_restore')
      autoload :WaitForState, action_root.join('wait_for_state')
    end
  end
end