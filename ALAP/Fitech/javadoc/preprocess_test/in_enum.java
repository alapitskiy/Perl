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
 * Created on 21.02.2009
 *
 * $Project$
 * $Workfile$
 * $Date$
 * $Revision$
 */

package com.fitechlabs.rbf.rules.impl.matchers.filters;

/**
 * The Enum OperatorType.
 */
public enum OperatorType {

    /** The equals. */
    EQUALS("="),

    /** The not equals. */
    NOT_EQUALS("!="),

    /** The greater. */
    GREATER(">"),

    /** The greater equals. */
    GREATER_EQUALS(">="),

    /** The lesser. */
    LESSER("<"),

    /** The lesser equals. */
    LESSER_EQUALS("<=");

    /** The symbol. */
    private final String symbol;

    /**
     * Instantiates a new operator type.
     *
     * @param operator the operator
     */
    OperatorType(String operator) {
        this.symbol = operator;
    }

    /**
     * Gets the symbol.
     *
     * @return the symbol
     */
    public String getSymbol() {
        return symbol;
    }

    /**
     * Gets the sql symbol.
     *
     * @return the sql symbol
     */
    public String getSqlSymbol() {
        if (this == NOT_EQUALS) {
            return "<>";
        }

        return symbol;
    }

    /**
     * Reverses.
     *
     * @return the operator type
     */
    public OperatorType reverse() {
        switch (this) {
            case GREATER: {
                return OperatorType.LESSER;
            }
            case GREATER_EQUALS: {
                return OperatorType.LESSER_EQUALS;
            }
            case LESSER: {
                return OperatorType.GREATER;
            }
            case LESSER_EQUALS: {
                return OperatorType.GREATER_EQUALS;
            }
            case EQUALS: {
                return this;
            }
            case NOT_EQUALS: {
                return this;
            }
            default: {
                throw new IllegalStateException("Unexpected operator type: " + this);
            }
        }
    }
}
