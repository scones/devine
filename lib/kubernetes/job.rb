require_relative 'abstract_resource'

module Kubernetes

  class Job < AbstractResource
    DEFAULT_TIMEOUT = 300

    attr_accessor :job

    def initialize name, task
      @name = name_from_task task

      job = template 'job'
      job.spec.template.spec.containers[0].name = @name
      job.spec.template.spec.containers[0].image = task.image
      job.metadata.name = @name
      job.metadata.namespace = Job::DEFAULT_NAMESPACE

      unless task.script.blank?
        job.spec.template.spec.containers[0].command = ["sh", "-c"]
        job.spec.template.spec.containers[0].args = [task.script]
      end

      variables = task.stage.pipeline.variables_hash.merge(task.variables_hash)
      job.spec.template.spec.containers[0].env ||= []

      variables.each do |key, value|
        job.spec.template.spec.containers[0].env[key] = value
      end

      @job = client.get_resource job
    rescue K8s::Error::NotFound => e
      @job = client.create_resource job
    end

    def self.create_from_task_and_wait task, timeout = Job::DEFAULT_TIMEOUT
      job = self.new name, task
      job.wait_for_completion timeout
      puts "yay"
    end

    def wait_for_completion timeout
      require 'timeout'
      Timeout::timeout(timeout) do
        loop do
          remote_job = client.get_resource(@job)
          return if 1 == remote_job.status.succeeded
        end
      end
    end


    private


    def name_from_task task
      slugify_name("p-#{task.stage.pipeline.id}-t-#{task.id}-#{task.name}")
    end

  end

end
