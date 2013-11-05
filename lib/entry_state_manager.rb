require 'subscriptions_manager'

##
# Class with methods related to changing the read/unread state of entries.

class EntryStateManager

  ##
  # Change the read or unread state of an entry, for a given user.
  #
  # Receives as arguments:
  # - the entry to be changed state
  # - the state in which to put it. Supported values are only "read" and "unread"; this method
  # does nothing if a different value is passed
  # - the user for which the state will be set.
  # - whole_feed (optional): boolean to indicate whether other entries in the same feed **older** than
  # the one passed as argument are to be changed state as well.
  # - whole_folder (optional): boolean to indicate whether other entries in the same folder **older** than
  # the one passed as argument are to be changed state as well.
  # - all_entries (optional): boolean to indicate whether **ALL** entries from all subscribed feeds **older**
  # than the one passed as argument are to be changed state as well.
  #
  # If the update_feed or update_folder optional named arguments are passed as true,
  # entries in the same feed/folder as the passed entry which either:
  # - have an older publish date than the passed entry
  # - or have the same publish date but a smaller id
  # are considered to be older and therefore set as read or unread depending on the "state" argument.

  def self.change_entries_state(entry, state, user, whole_feed: false, whole_folder: false, all_entries: false)
    if state == 'read'
      read = true
    elsif state == 'unread'
      read = false
    else
      return nil
    end

    if !whole_feed && !whole_folder && !all_entries
      # Update a single entry
      entry_state = EntryState.where(user_id: user.id, entry_id: entry.id).first
      entry_state.read = read
      entry_state.save!
    else
      change_feed_entries_state entry, read, user if whole_feed
      change_folder_entries_state entry, read, user if whole_folder
      change_all_entries_state entry, read, user if all_entries
    end

    return nil
  end

  private

  ##
  # Change the read/unread state for all entries in a feed older than the passed entry.
  #
  # Receives as arguments:
  # - entry: this entry, and all entries in the same feed older than this one, will be marked as read.
  # - read: boolean argument indicating if entries will be marked as read (true) or unread (false).
  # - user: user for whom the read/unread state will be set.

  def self.change_feed_entries_state(entry, read, user)
    # Join with entry_states to select only those entries that don't already have the desired state.
    entries = Entry.joins(:entry_states).where(entry_states: {user_id: user.id, read: !read}).
      where('entries.feed_id=? AND (entries.published<? OR (entries.published=? AND entries.id<= ?))',
            entry.feed_id, entry.published, entry.published, entry.id)
    entries.each do |e|
      entry_state = EntryState.where(user_id: user.id, entry_id: e.id).first
      entry_state.read = read
      entry_state.save!
    end
  end

  ##
  # Change the read/unread state for all entries in a folder older than the passed entry.
  #
  # Receives as arguments:
  # - entry: this entry, and all entries in the same feed older than this one, will be marked as read.
  # - read: boolean argument indicating if entries will be marked as read (true) or unread (false).
  # - user: user for whom the read/unread state will be set.

  def self.change_folder_entries_state(entry, read, user)
    folder = entry.feed.user_folder user
    # Join with entry_states to select only those entries that don't already have the desired state.
    entries = Entry.joins(:entry_states, feed: :folders).
      where(entry_states: {user_id: user.id, read: !read}, folders: {id: folder.id}).
      where('entries.published<? OR (entries.published=? AND entries.id<= ?)',
            entry.published, entry.published, entry.id)
    entries.each do |e|
      entry_state = EntryState.where(user_id: user.id, entry_id: e.id).first
      entry_state.read = read
      entry_state.save!
    end
  end

  ##
  # Change the read/unread state for all entries in all subscribed feeds.
  #
  # Receives as arguments:
  # - entry: this entry, and all entries in subscribed feeds older than this one, will be marked as read.
  # - read: boolean argument indicating if entries will be marked as read (true) or unread (false).
  # - user: user for whom the read/unread state will be set.

  def self.change_all_entries_state(entry, read, user)
    # Join with entry_states to select only those entries that don't already have the desired state.
    entries = Entry.joins(:entry_states).where(entry_states: {user_id: user.id, read: !read}).
      where('entries.published<? OR (entries.published=? AND entries.id<= ?)',
            entry.published, entry.published, entry.id)
    entries.each do |e|
      entry_state = EntryState.where(user_id: user.id, entry_id: e.id).first
      entry_state.read = read
      entry_state.save!
    end
  end
end