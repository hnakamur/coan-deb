{
    printf("overrides:\n")
    printf("  deb:\n")
    printf("    depends:\n")
    for (i = 1; i <= NF; i++) {
        printf("     - %s\n", $i)
    }
}
