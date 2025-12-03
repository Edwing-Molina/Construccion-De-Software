<?php

namespace Tests\Unit\Enums;

use App\Enums\Genres;
use Tests\TestCase;

class GenresEnumTest extends TestCase
{
    /**
     * Test genres enum cases exist
     */
    public function test_genres_enum_cases_exist(): void
    {
        $this->assertEquals('masculino', Genres::Masculino->value);
        $this->assertEquals('femenino', Genres::Femenino->value);
        $this->assertEquals('prefiero no decirlo', Genres::Prefiero_no_decirlo->value);
    }

    /**
     * Test genres to array method
     */
    public function test_genres_to_array_method(): void
    {
        $array = Genres::toArray();

        $this->assertIsArray($array);
        $this->assertEquals(3, count($array));
        $this->assertContains('masculino', $array);
        $this->assertContains('femenino', $array);
    }

    /**
     * Test genres has all cases
     */
    public function test_genres_has_all_cases(): void
    {
        $cases = Genres::cases();
        $this->assertEquals(3, count($cases));
    }

    /**
     * Test genres can be compared
     */
    public function test_genres_can_be_compared(): void
    {
        $this->assertTrue(Genres::Masculino->value === 'masculino');
        $this->assertFalse(Genres::Femenino->value === 'masculino');
    }
}
