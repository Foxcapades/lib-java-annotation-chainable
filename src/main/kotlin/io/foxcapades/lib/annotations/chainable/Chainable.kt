package io.foxcapades.lib.annotations.chainable

/**
 * # Chainable Method
 *
 * This annotation may be used on a class method to indicate that the method
 * returns the parent class instance for method chaining.
 *
 * An examples of such methods can be found on builder types like
 * [StringBuilder], where the type's `append` methods return the `StringBuilder`
 * instance on which they were called.
 *
 * @author Elizabeth Harper [foxcapade@gmail.com]
 */
@Target(AnnotationTarget.FUNCTION)
@Retention(AnnotationRetention.SOURCE)
@MustBeDocumented
annotation class Chainable
