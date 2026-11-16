package org.sonatype.nexus.plugins.githuboauth;

import java.util.List;
import java.util.Map;

import org.apache.shiro.realm.Realm;
import org.junit.Test;
import org.sonatype.nexus.common.QualifierUtil;
import org.springframework.beans.factory.support.AbstractBeanDefinition;
import org.springframework.context.annotation.AnnotationConfigApplicationContext;
import org.springframework.context.annotation.ClassPathBeanDefinitionScanner;
import org.springframework.context.annotation.FullyQualifiedAnnotationBeanNameGenerator;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertSame;
import static org.junit.Assert.assertTrue;

/**
 * Mirrors how Nexus 3.93's {@code SpringComponentScan} builds its child context and how
 * {@code RealmManagerImpl} turns the {@code List<Realm>} into its available-realms map, to check
 * the realm is discovered under the expected id without any manual registration.
 */
public class GithubOauthRealmRegistrationTest {

    @Test
    public void realmIsDiscoveredByComponentScanUnderConfiguredName() {
        try (AnnotationConfigApplicationContext context = new AnnotationConfigApplicationContext()) {
            ClassPathBeanDefinitionScanner scanner = new ClassPathBeanDefinitionScanner(context);
            scanner.setBeanNameGenerator(new FullyQualifiedAnnotationBeanNameGenerator());
            scanner.getBeanDefinitionDefaults().setAutowireMode(AbstractBeanDefinition.AUTOWIRE_CONSTRUCTOR);
            scanner.scan("org.sonatype.nexus.plugins.githuboauth");
            context.refresh();

            List<Realm> realms = List.copyOf(context.getBeansOfType(Realm.class).values());
            Map<String, Realm> available = QualifierUtil.buildQualifierBeanMap(realms);

            Realm realm = available.get(GithubOauthAuthenticatingRealm.NAME);
            assertTrue("realm not found under its NAME, available: " + available.keySet(),
                    realm instanceof GithubOauthAuthenticatingRealm);
            assertEquals(GithubOauthAuthenticatingRealm.NAME, realm.getName());
            assertSame(realm, context.getBean(GithubOauthAuthenticatingRealm.class));
        }
    }
}
