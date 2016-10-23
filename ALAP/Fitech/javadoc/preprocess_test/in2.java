// TODO: Auto-generated Javadoc
/**
 * Default implementation of {@link Entity} interface.
 *
 * @param <T> Entity type - an enumeration describing entity fields structure (see {@link #getType()}).
 */
public class DefaultEntity<T extends Enum<T>> implements Entity<T> {

    /** The Constant serialVersionUID. */
    private static final long serialVersionUID = -959792276355345481L;

    /** The Constant log. */
    private static final Log log = Log.getLogger(EntityProxy.class);

    /** The constant log. */
    private static final Log log = Log.getLogger(EntityProxy.class);

    /** */
    private static final java.util.regex.Pattern CLASS_NAME_PATTER = java.util.regex.Pattern.compile("/");

    /** The typ. e. */
    private final Class<T> typ;

    /** The un d */
    regex.fuck.UnDone unD = new UnDone();

    /** T key t Key */
    private final T key;

    /** The stat. */
    private EntityStatus< ?, Fuck<lo<?>> > stat;

    /** The stat. */
    private EntityStatus[] stat;

    /** The en stat. */
    private EntityStatus[][] enStat;

    /** The stat. */
    private EntityStatus< Lohi<?>>[] stat = new EntityStatus<Lohi>();

    /** The id. */
    private String id;

    /** The has item */
    private Boolean hasItem;

    /** The has item */
    boolean hasItem;

    /** The persistent. */
    @XmlAttribute(name = "persistent")
    private Boolean persistent;

    /** The seq num column. */
    @XmlElement(name = "seq-num-column")
    private String seqNumColumn;

    // /** fucking

    /**
     * Constructs new entity of the specified type with specified ID.
     *
     * @param id Entity ID (see {@link Entity#getId()}).
     * @param type Entity type (see {@link Entity#getType()}).
     */
    public DefaultEntity(String id, Class<T> type) {
        this(type);

        this.id = id;
    }

    /**
     * Constructs new entity and copies all fields values from the source ent p.
     *
     * @param source Source ent p.
     */
    public DefaultEntity(EntityParent<T> entP) {
        this(source, null);
    }

    /**
     * \{@inheritDoc}<>=.
     *
     * @param parent the new parent
     */
    @Override
    public void setParent(EntityParent<?> parent) {
        Entity<?> oldParent = this.parent;

        if (oldParent != null) {
            oldParent.removeChild(this);
        }

        this.parent = parent;
    }
}