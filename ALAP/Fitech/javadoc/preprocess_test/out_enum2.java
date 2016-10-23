/*
 * Copyright 2000-2004 Fitech Laboratories, Inc. All Rights Reserved.
 *
 * This software is provided "AS IS," without a warranty of any kind. ALL
 * EXPRESS OR IMPLIED CONDITIONS, REPRESENTATIONS AND WARRANTIES, INCLUDING ANY
 * IMPLIED WARRANTY OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE OR
 * NON-INFRINGEMENT, ARE HEREBY EXCLUDED. FITECH LABORATORIES AND ITS LICENSORS
 * SHALL NOT BE LIABLE FOR ANY DAMAGES SUFFERED BY LICENSEE AS A RESULT OF USING,
 * MODIFYING OR DISTRIBUTING THE SOFTWARE OR ITS DERIVATIVES. IN NO EVENT WILL
 * FITECH LABORATORIES OR ITS LICENSORS BE LIABLE FOR ANY LOST REVENUE, PROFIT
 * OR DATA, OR FOR DIRECT, INDIRECT, SPECIAL, CONSEQUENTIAL, INCIDENTAL OR PUNITIVE
 * DAMAGES, HOWEVER CAUSED AND REGARDLESS OF THE THEORY OF LIABILITY, ARISING OUT
 * OF THE USE OF OR INABILITY TO USE SOFTWARE, EVEN IF FITECH LABORATORIES HAS
 * BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.
 *
 * This software is not designed or intended for use in on-line control of
 * aircraft, air traffic, aircraft navigation or aircraft communications; or in
 * the design, construction, operation or maintenance of any nuclear
 * facility. Licensee represents and warrants that it will not use or
 * redistribute the Software for such purposes.
 *
 * Created on 14.04.2009
 *
 * $Project$
 * $Workfile$
 * $Date$
 * $Revision$
 */

package com.fitechlabs.rbf.rules.impl.parser;

/**
 * The Enum ExpressionType.
 */
public enum ExpressionType {
    /** The attribute. */
    ATTRIBUTE,

    /** The parameter. */
    PARAMETER,

    /** The constant. */
    CONSTANT,

    /** The mixed. */
    MIXED,

    /** The functional. */
    FUNCTIONAL;

    /**
     * Adapts.
     *
     * @param other the other
     * @return the expression type
     */
    public ExpressionType adapt(ExpressionType other) {
        if (this == CONSTANT) {
            return other;
        }
        else if (other == CONSTANT) {
            return this;
        }
        else if (this == FUNCTIONAL) {
            return this;
        }
        else if (this == ATTRIBUTE && other == ATTRIBUTE) {
            return ATTRIBUTE;
        }
        else if (this == PARAMETER && other == PARAMETER) {
            return PARAMETER;
        }
        else {
            return MIXED;
        }
    }
}
