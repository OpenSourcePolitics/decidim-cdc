# frozen_string_literal: true

# This migration comes from decidim_sortitions (originally 20180103160301)

class AddCancelDataToSortition < ActiveRecord::Migration[5.1]
  def change
    add_column :decidim_module_sortitions_sortitions, :cancel_reason, :jsonb
    add_column :decidim_module_sortitions_sortitions, :cancelled_on, :datetime
    # rubocop:disable Rails/AddColumnIndex
    add_column :decidim_module_sortitions_sortitions, :cancelled_by_user_id, :integer, index: true
    # rubocop:enable Rails/AddColumnIndex
  end
end
