package input

import java.io.FileNotFoundException

fun read(name: String, trim: Boolean = true): List<String> {
    val classLoader = object {}.javaClass.classLoader
    val inputStream = classLoader.getResourceAsStream(name) ?: throw FileNotFoundException()

    return inputStream.bufferedReader().use { it.readText() }
        .split("\n")
        .map { if (trim) it.trim() else it }
        .filter { it.isNotBlank() }
}

fun raw(name: String): String {
    val classLoader = object {}.javaClass.classLoader
    val inputStream = classLoader.getResourceAsStream(name) ?: throw FileNotFoundException()

    return inputStream.bufferedReader().use { it.readText() }
}
