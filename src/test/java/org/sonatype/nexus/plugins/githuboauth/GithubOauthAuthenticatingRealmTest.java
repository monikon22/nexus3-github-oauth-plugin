package org.sonatype.nexus.plugins.githuboauth;

import java.util.Set;

import org.apache.shiro.subject.PrincipalCollection;
import org.apache.shiro.subject.SimplePrincipalCollection;
import org.junit.Test;

import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;
import static org.mockito.Mockito.mock;

public class GithubOauthAuthenticatingRealmTest {

    private final GithubOauthAuthenticatingRealm realm =
            new GithubOauthAuthenticatingRealm(mock(GithubApiClient.class));

    @Test
    public void githubPrincipalRolesAreAuthorized() {
        GithubPrincipal principal = new GithubPrincipal();
        principal.setUsername("user");
        principal.setRoles(Set.of("org/team"));
        PrincipalCollection principals =
                new SimplePrincipalCollection(principal, GithubOauthAuthenticatingRealm.NAME);

        assertTrue(realm.hasRole(principals, "org/team"));
        assertFalse(realm.hasRole(principals, "org/other"));
    }

    @Test
    public void stringPrincipalIsIgnoredInsteadOfThrowing() {
        PrincipalCollection principals =
                new SimplePrincipalCollection("user", GithubOauthAuthenticatingRealm.NAME);

        assertFalse(realm.hasRole(principals, "org/team"));
    }
}
