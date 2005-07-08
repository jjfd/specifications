indexing
	component:   "openEHR EHR Extract Reference Model"

	description: "[
			 Container class for all access control data required in an EHR Extract. 
			 The list of Access groups must be supplied except in the case 
			 when an EHR extract is sent within the one environment, 
			 and the receiver system has access to the same access control 
			 server as the sender.	

			 ]"
	keywords:    "access control, extract"

	requirements:"ISO 18308 TS V1.0 ???"
	design:      "openEHR EHR Extract Reference Model 1.3.1"

	author:      "Thomas Beale"
	support:     "Ocean Informatics <support@OceanInformatics.biz>"
	copyright:   "Copyright (c) 2000-2004 The openEHR Foundation <http://www.openEHR.org>"
	license:     "See notice at bottom of class"

	file:        "$Source: C:/project/openehr/spec-dev/architecture/computable/eiffel/rm/ehr_extract/SCCS/s.x_access_control.e $"
	revision:    "$Revision: 1.2 $"
	last_change: "$Date: 04/03/11 21:08:32+10:00 $"

class X_ACCESS_CONTROL

feature -- Access

	groups: TABLE[ACCESS_GROUP, OBJECT_ID]	
			-- Access groups referred to in this extract.

	details: ITEM_STRUCTURE	
			-- Other access control details.

	group(key: OBJECT_ID): ACCESS_GROUP	is
			-- Obtain the access group for the given key.
		do
		end

invariant
	Groups_validity: groups /= Void implies not groups.empty	

end


--|
--| ***** BEGIN LICENSE BLOCK *****
--| Version: MPL 1.1/GPL 2.0/LGPL 2.1
--|
--| The contents of this file are subject to the Mozilla Public License Version
--| 1.1 (the 'License'); you may not use this file except in compliance with
--| the License. You may obtain a copy of the License at
--| http://www.mozilla.org/MPL/
--|
--| Software distributed under the License is distributed on an 'AS IS' basis,
--| WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License
--| for the specific language governing rights and limitations under the
--| License.
--|
--| The Original Code is x_access_control.e.
--|
--| The Initial Developer of the Original Code is Thomas Beale.
--| Portions created by the Initial Developer are Copyright (C) 2003-2004
--| the Initial Developer. All Rights Reserved.
--|
--| Contributor(s):
--|
--| Alternatively, the contents of this file may be used under the terms of
--| either the GNU General Public License Version 2 or later (the 'GPL'), or
--| the GNU Lesser General Public License Version 2.1 or later (the 'LGPL'),
--| in which case the provisions of the GPL or the LGPL are applicable instead
--| of those above. If you wish to allow use of your version of this file only
--| under the terms of either the GPL or the LGPL, and not to allow others to
--| use your version of this file under the terms of the MPL, indicate your
--| decision by deleting the provisions above and replace them with the notice
--| and other provisions required by the GPL or the LGPL. If you do not delete
--| the provisions above, a recipient may use your version of this file under
--| the terms of any one of the MPL, the GPL or the LGPL.
--|
--| ***** END LICENSE BLOCK *****
--|
