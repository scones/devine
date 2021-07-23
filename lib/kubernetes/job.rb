require_relative 'abstract_resource'

module Kubernetes

  class Job < AbstractResource
    DEFAULT_TIMEOUT = 300

    attr_accessor :job, :resource

    def initialize job, resource
      @job = @job
      @resource = @resource
    end

    def self.fetch_job task
      resource = resource_from_task task
      job = Job.client.get_resource @resource

      self.new job, resource
    end

    def self.build_job task
      resource = resource_from_task task

      resource.spec.template.spec.containers[0].name = task.job_name
      resource.spec.template.spec.containers[0].image = task.image

      unless task.script.blank?
        resource.spec.template.spec.containers[0].command = ["sh", "-c"]
        resource.spec.template.spec.containers[0].args = [task.script]
      end

      resource.spec.template.spec.containers[0].env ||= []
      task.effective_variables.each do |key, value|
        resource.spec.template.spec.containers[0].env << {name: key.upcase, value: "#{value}"}
      end

      job = Job.client.create_resource resource

      self.new job, resource
    end

    def self.fetch_or_build_job task
      fetch_job task
    rescue K8s::Error::NotFound => e
      build_job task
    end

    def self.resource_from_task task
      resource = Job.resource_from_template 'job'
      resource.metadata.name = task.job_name
      resource.metadata.namespace = Job::DEFAULT_NAMESPACE
      resource
    end

    def self.create_from_task_and_wait task, timeout = Job::DEFAULT_TIMEOUT
      job = create_from_task task
      job.wait_for_completion timeout
    end

    def wait_for_completion timeout
      require 'timeout'
      Timeout::timeout(timeout) do
        loop do
          remote_job = Job.client.get_resource(@job)
          return if 1 == remote_job.status.succeeded
        end
      end
    end

  end

end
