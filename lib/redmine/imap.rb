# frozen_string_literal: false

# Redmine - project management software
# Copyright (C) 2006-2019  Jean-Philippe Lang
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

require 'net/imap'

module Redmine
  module IMAP
    class << self
      def check(imap_options={}, options={})
        logger.info "MailHandler: Initiating check time: #{Time.now.getutc} "
        host = imap_options[:host] || '127.0.0.1'
        port = imap_options[:port] || '143'
        ssl = !imap_options[:ssl].nil?
        starttls = !imap_options[:starttls].nil?
        folder = imap_options[:folder] || 'INBOX'

        logger.info "MailHandler: Variables host: #{host} port: #{port} ssl: #{ssl} time: #{Time.now.getutc} "

        imap = Net::IMAP.new(host, port, ssl)
        if starttls
          imap.starttls
        end
        logger.info "MailHandler: Login with #{imap_options[:username]} time: #{Time.now.getutc} "
        imap.login(imap_options[:username], imap_options[:password]) unless imap_options[:username].nil?
        logger.info "MailHandler: Login DONE! time: #{Time.now.getutc} "

        imap.select(folder)

        logger.info "MailHandler: Select Folder DONE! time: #{Time.now.getutc} "

        imap.uid_search(['NOT', 'SEEN']).each do |uid|
          logger.info "MailHandler: Searching message #{uid} time: #{Time.now.getutc} "
          msg = imap.uid_fetch(uid,'RFC822')[0].attr['BODY[]']
          logger.info "MailHandler: Receiving message #{uid} time: #{Time.now.getutc}"
          if MailHandler.safe_receive(msg, options)
            logger.info "MailHandler: successfully message #{uid} time: #{Time.now.getutc}"
            logger.debug "Message #{uid} successfully received" if logger && logger.debug?
            if imap_options[:move_on_success]
              logger.info "MailHandler: move on success message #{uid} time: #{Time.now.getutc}"
              imap.uid_copy(uid, imap_options[:move_on_success])
            end
            imap.uid_store(uid, "+FLAGS", [:Seen])
            logger.info "MailHandler: Seen and deleted message #{uid} time: #{Time.now.getutc}"
          else
            logger.debug "Message #{uid} can not be processed" if logger && logger.debug?
            imap.uid_store(uid, "+FLAGS", [:Seen])
            if imap_options[:move_on_failure]
              imap.uid_copy(uid, imap_options[:move_on_failure])
              imap.uid_store(uid, "+FLAGS", [:Deleted])
            end
          end
        end
        imap.expunge
        imap.logout
        imap.disconnect
      end

      def check_pair(imap_options={}, options={})
        logger.info "MailHandler: PAIR Initiating check pair time: #{Time.now.getutc} "
        host = imap_options[:host] || '127.0.0.1'
        port = imap_options[:port] || '143'
        ssl = !imap_options[:ssl].nil?
        starttls = !imap_options[:starttls].nil?
        folder = imap_options[:folder] || 'INBOX'
        logger.info "MailHandler: PAIR Variables host: #{host} port: #{port} ssl: #{ssl} time: #{Time.now.getutc} "

        imap = Net::IMAP.new(host, port, ssl)
        if starttls
          imap.starttls
        end
        logger.info "MailHandler: PAIR Login with #{imap_options[:username]} time: #{Time.now.getutc} "

        imap.login(imap_options[:username], imap_options[:password]) unless imap_options[:username].nil?
        logger.info "MailHandler: PAIR Login DONE! time: #{Time.now.getutc} "

        imap.select(folder)
        logger.info "MailHandler: PAIR Select Folder DONE! time: #{Time.now.getutc} "

        logger.info "MailHandler: PAIR NotSeen Search pair time: #{Time.now.getutc} "
        imap.uid_search(['NOT', 'SEEN']).each do |uid|
          remainder = uid % 2
          logger.info "MailHandler: PAIR Reading UID #{uid} Remainder #{remainder}  time: #{Time.now.getutc} "
          if remainder == 0
            logger.info "MailHandler: PAIR Searching message pair #{uid} time: #{Time.now.getutc} "
            msg = imap.uid_fetch(uid,'RFC822')[0].attr['BODY[]']
            logger.info "MailHandler: PAIR Receiving message #{uid} time: #{Time.now.getutc}"
            if MailHandler.safe_receive(msg, options)
              logger.info "MailHandler: PAIR successfully message #{uid} time: #{Time.now.getutc}"
              logger.debug "Message #{uid} successfully received" if logger && logger.debug?
              if imap_options[:move_on_success]
                logger.info "MailHandler: PAIR move on success message #{uid} time: #{Time.now.getutc}"
                imap.uid_copy(uid, imap_options[:move_on_success])
              end
              imap.uid_store(uid, "+FLAGS", [:Seen])
              logger.info "MailHandler: PAIR Seen and deleted message #{uid} time: #{Time.now.getutc}"
            else
              logger.debug "PAIR Message #{uid} can not be processed" if logger && logger.debug?
              imap.uid_store(uid, "+FLAGS", [:Seen])
              if imap_options[:move_on_failure]
                imap.uid_copy(uid, imap_options[:move_on_failure])
                imap.uid_store(uid, "+FLAGS", [:Deleted])
              end
            end
          end
        end
        imap.expunge
        imap.logout
        imap.disconnect
      end

      def check_odd(imap_options={}, options={})
        logger.info "MailHandler: Initiating odd time: #{Time.now.getutc} "

        host = imap_options[:host] || '127.0.0.1'
        port = imap_options[:port] || '143'
        ssl = !imap_options[:ssl].nil?
        starttls = !imap_options[:starttls].nil?
        folder = imap_options[:folder] || 'INBOX'

        imap = Net::IMAP.new(host, port, ssl)
        if starttls
          imap.starttls
        end
        logger.info "MailHandler: Login odd time: #{Time.now.getutc} "
        imap.login(imap_options[:username], imap_options[:password]) unless imap_options[:username].nil?
        imap.select(folder)
        logger.info "MailHandler: NotSeen Search odd time: #{Time.now.getutc} "
        imap.uid_search(['NOT', 'SEEN']).each do |uid|
          remainder = uid % 2
          logger.info "MailHandler: Reading UID #{uid} Remainder #{remainder}  time: #{Time.now.getutc} "
          if remainder != 0
            logger.info "MailHandler: Searching message odd #{uid} time: #{Time.now.getutc} "
            msg = imap.uid_fetch(uid,'RFC822')[0].attr['BODY[]']
            logger.info "MailHandler: Receiving message #{uid} time: #{Time.now.getutc}"
            if MailHandler.safe_receive(msg, options)
              logger.info "MailHandler: successfully message #{uid} time: #{Time.now.getutc}"
              logger.debug "Message #{uid} successfully received" if logger && logger.debug?
              if imap_options[:move_on_success]
                logger.info "MailHandler: move on success message #{uid} time: #{Time.now.getutc}"
                imap.uid_copy(uid, imap_options[:move_on_success])
              end
              imap.uid_store(uid, "+FLAGS", [:Seen])
              logger.info "MailHandler: Seen and deleted message #{uid} time: #{Time.now.getutc}"
            else
              logger.debug "Message #{uid} can not be processed" if logger && logger.debug?
              imap.uid_store(uid, "+FLAGS", [:Seen])
              if imap_options[:move_on_failure]
                imap.uid_copy(uid, imap_options[:move_on_failure])
                imap.uid_store(uid, "+FLAGS", [:Deleted])
              end
            end
          end
        end
        imap.expunge
        imap.logout
        imap.disconnect
      end

      private

      def logger
        ::Rails.logger
      end
    end
  end
end
