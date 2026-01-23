class CreateSolidQueueTables < ActiveRecord::Migration[8.1]
  def change
    create_table :solid_queue_jobs do |t|
      t.string :queue_name, null: false
      t.string :class_name, null: false, index: true
      t.text :arguments
      t.integer :priority, default: 0, null: false
      t.string :active_job_id, index: true
      t.datetime :scheduled_at
      t.datetime :finished_at, index: true
      t.string :concurrency_key
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end

    create_table :solid_queue_scheduled_executions do |t|
      t.references :job, index: { unique: true }, null: false
      t.string :queue_name, null: false
      t.integer :priority, default: 0, null: false
      t.datetime :scheduled_at, null: false, index: true
      t.datetime :created_at, null: false
    end

    create_table :solid_queue_ready_executions do |t|
      t.references :job, index: { unique: true }, null: false
      t.string :queue_name, null: false
      t.integer :priority, default: 0, null: false
      t.datetime :created_at, null: false
    end

    create_table :solid_queue_claimed_executions do |t|
      t.references :job, index: { unique: true }, null: false
      t.bigint :process_id, index: true
      t.datetime :created_at, null: false
    end

    create_table :solid_queue_blocked_executions do |t|
      t.references :job, index: { unique: true }, null: false
      t.string :queue_name, null: false
      t.integer :priority, default: 0, null: false
      t.string :concurrency_key, null: false, index: true
      t.datetime :expires_at, null: false, index: true
      t.datetime :created_at, null: false
    end

    create_table :solid_queue_pauses do |t|
      t.string :queue_name, null: false, index: { unique: true }
      t.datetime :created_at, null: false
    end

    create_table :solid_queue_processes do |t|
      t.string :kind, null: false, index: true
      t.datetime :last_heartbeat_at, null: false, index: true
      t.bigint :supervisor_id, index: true
      t.integer :pid, null: false
      t.string :hostname
      t.text :metadata
      t.datetime :created_at, null: false
      t.string :name, null: false
    end

    create_table :solid_queue_failed_executions do |t|
      t.references :job, index: { unique: true }, null: false
      t.text :error
      t.datetime :created_at, null: false
    end

    create_table :solid_queue_semaphores do |t|
      t.string :key, null: false, index: { unique: true }
      t.integer :value, default: 1, null: false
      t.datetime :expires_at, null: false, index: true
      t.datetime :created_at, null: false
      t.datetime :updated_at, null: false
    end

    # Note: Add other tables from your schema (recurring_tasks, etc.) here if needed
  end
end