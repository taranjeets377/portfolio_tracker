# Module for migration helper methods to be used in migration files.
module MigrationHelpers
  def add_reference_with_index(table, reference)
    add_reference table, reference, foreign_key: true, index: true
  end
end
